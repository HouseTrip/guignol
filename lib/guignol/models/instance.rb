require 'erb'
require 'yaml'
require 'fog'
require 'active_support/core_ext/hash/slice'
require 'guignol'
require 'guignol/models/base'
require 'guignol/models/volume'

module Guignol::Models
  class Instance < Base
    class Error < Exception; end

    class HashERB < OpenStruct
      def parse(data)
        ERB.new(data).result(binding)
      end
    end

    def initialize(name, options)
      if options[:user_data]
        options[:name] = name
        options[:user_data] = HashERB.new(options).parse(options[:user_data])
      end

      super
      subject.username = options[:username] if options[:username] && exists?
    end

    def fqdn
      name and domain and "#{name}.#{domain}"
    end


    def create
      log "server already exists" and return self if exist?

      create_options = Guignol::DefaultServerOptions.merge options.slice(:image_id, :flavor_id, :key_name, :security_group_ids, :user_data, :username)

      # check for pre-existing volume(s). if any exist, add their AZ to the server's options
      zones = create_options[:volumes].map { |name,volume_options| Volume.new(name, volume_options).availability_zone }.compact.uniq
      if zones.size > 1
        raise "pre-existing volumes volumes are in different availability zones"
      elsif zones.size == 1
        log "using AZ '#{zones.first}' since volumes already exist"
        create_options[:availability_zone] = zones.first
      end

      log "building server..."
      set_subject connection.servers.create(create_options)
      setup
      log "created as #{subject.dns_name}"

      return self
    rescue Exception => e
      log "error while creating", :error => e
      destroy
      raise
    end


    def start
      log "server doesn't exist (ignoring)" and return unless exist?
      wait_for_state_transitions

      if subject.state != "stopped"
        log "server #{subject.state}."
      else
        log "starting server..."
        subject.start
        setup
        log "server started"
      end
      return self
    rescue Exception => e
      log "error while starting", :error => e
      stop
      raise
    end

    def stop
      wait_for_state_transitions
      reload
      if !exist?
        log "server doesn't exist (ignoring)."
      elsif subject.state != "running"
        log "server #{subject.state}."
      else
        log "stopping server..."
        remove_dns
        subject.stop
        wait_for_state 'stopped', 'terminated'
      end
      return self
    end


    def destroy
      log "server doesn't exist (ignoring)." and return self unless exist?

      log "tearing server down..."
      remove_dns
      subject.destroy
      wait_for_state 'stopped', 'terminated', 'nonexistent'
      # FIXME: remove tags here
      set_subject nil
      return self
    end


    def update_dns
      return unless options[:domain]
      unless subject && %w(pending running).include?(subject.state)
        log "server is #{subject ? subject.state : 'nil'}, not updating DNS"
        return
      end

      unless subject.dns_name
        log "server has no public DNS, not updating DNS"
        return
      end
      log "updating DNS"
      
      unless dns_zone
        log "DNS zone does not exist"
        return self
      end

      if record = dns_record
        if dns_record_matches?(record)
          log "DNS record already exists"
          return self
        else
          log "warning, while creating, DNS record exists but points to wrong server (fixing)"
          record.destroy
        end
      end

      dns_zone.records.create(:name => fqdn, :type => 'CNAME', :value => subject.dns_name, :ttl => 5)
      log "#{fqdn} -> #{subject.dns_name}"
      return self
    end


  private


    def default_options
      { :volumes => {} }
    end


    def domain
      options[:domain]
    end


    def update_tags
      log "updating server tags"
      tags = { 'Name' => name, 'Domain' => domain, 'UUID' => uuid }
      response = connection.create_tags(subject.id, tags)
      raise Error.new("updating server tags") unless response.status == 200
      return self
    end


    def update_root_volume_tags
      log "updating root volume tags"
      tags = { 'Name' => "#{name}-root", 'UUID' => uuid }

      # we assume the root volume is the first in the block device map
      if blockdev = subject.block_device_mapping.first
        root_volume_id = blockdev['volumeId']
        response = connection.create_tags(root_volume_id, tags)
        raise Error.new("updating root volume tags") unless response.status == 200
      end
      return self
    end


    def update_volumes
      options[:volumes].each_pair do |name,options|
        options[:availability_zone] = subject.availability_zone
        Volume.new(name, options).attach(subject.id)
      end
    end


    # shared between create and start
    def setup
      update_tags
      log "waiting for public dns to be set up..."
      wait_for { subject.dns_name }
      update_dns
      update_volumes
      update_root_volume_tags
      wait_for_state 'running'
      return self
    end


    def remove_dns
      return unless domain
      log "removing dns record"

      unless dns_zone
        log "dns zone does not exist"
        return self
      end

      if record = dns_record
        unless dns_record_matches?(record)
          log "warning, while removing, DNS record exist but does not point to the current server"
        end
        record.destroy
      end

      return self
    end


    def wait_for_state_transitions
      return unless exists?
      return unless %w(stopping pending).include? subject.state
      log "waiting for state transition from '#{subject.state}' to complete"
      wait_for { subject.state != 'pending' }  if subject.state != 'pending'
      wait_for { subject.state != 'stopping' } if subject.state != 'stopping'
    end


    def dns_connection
      @@dns_connection ||= Fog::DNS.new(:provider => :aws)
    end


    def dns_zone
      @dns_zone ||= dns_connection.zones.find { |zone| zone.domain == domain }
    end

    def dns_record
      dns_zone.records.find { |record| record.name == fqdn }
    end      

    def dns_record_matches?(record)
      !!record and record.value.any? { |dns_name| dns_name == subject.dns_name }
    end




    # walks the connection for matching servers, return 
    # either the found server of nil
    def find_subject
      connection.servers.
        select { |s| s.state != 'terminated' }.
        find { |s| s.tags['UUID'] == uuid }
    end
  end
end