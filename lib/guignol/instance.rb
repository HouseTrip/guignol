require 'yaml'
require 'fog'
require 'md5'
require 'active_support/core_ext/hash/slice'
require 'guignol'
require 'guignol/shared'
require 'guignol/volume'

module Guignol
  class Instance
    include Shared

    def initialize(options)
      @options = options.dup
      require_options :name, :uuid

      @options[:volumes] ||= []
      connection_options = DefaultConnectionOptions.dup.merge @options.slice(:region)

      @connection = Fog::Compute.new(connection_options)

      @subject = @connection.servers.
        select { |s| s.state != 'terminated' }.
        find { |s| s.tags['UUID'] == uuid }
    end


    def exist?
      !!@subject
    end


    def name
      @options[:name]
    end


    def domain
      @options[:domain]
    end


    def uuid
      @options[:uuid]
    end


    def fqdn
      name and domain and "#{name}.#{domain}"
    end

    def state
      exist? and @subject.state or 'nonexistent'
    end

    def create
      log "server already exists" and return self if exist?
        
      options = DefaultServerOptions.dup.merge @options.slice(:image_id, :flavor_id, :key_name, :security_group_ids, :user_data)

      # check for pre-existing volume(s). if any exist, add their AZ to the server's options
      zones = @options[:volumes].map { |volume_options| Volume.new(volume_options).availability_zone }.compact.uniq
      if zones.size > 1
        raise "pre-existing volumes volumes are in different availability zones"
      elsif zones.size == 1
        log "using AZ '#{zones.first}' since volumes already exist"
        options[:availability_zone] = zones.first
      end

      log "building server..."
      @subject = @connection.servers.create(options)
      setup
      log "created as #{@subject.dns_name}"

      return self
    rescue Exception => e
      log "error while creating (#{e.class.name})"
      destroy
      raise
    end


    def start
      log "server doesn't exist (ignoring)" and return unless exist?
      wait_for_state_transitions

      if @subject.state != "stopped"
        log "server #{@subject.state}."
      else
        log "starting server..."
        @subject.start
        setup
        log "server started"
      end
      return self
    end

    # shared between create and start
    def setup
      update_tags
      log "waiting for public dns to be set up..."
      wait_for { @subject.dns_name }
      update_dns
      update_volumes
      wait_for_state 'running'
      return self
    end

    def stop
      wait_for_state_transitions
      if !exist?
        log "server doesn't exist (ignoring)."
      elsif @subject.state != "running"
        log "server #{@subject.state}."
      else
        log "stopping server..."
        remove_dns
        @subject.stop
        wait_for_state 'stopped', 'terminated'
      end
      return self
    end


    def destroy
      if !exist?
        log "server doesn't exist (ignoring)."
      else
        log "tearing server down..."
        remove_dns
        @subject.destroy
        wait_for_state 'stopped', 'terminated'
        # FIXME: remove tags here
        @subject = nil
      end
      return self
    end


    def update_tags
      log "updating server tags"
      tags = { 'Name' => name, 'Domain' => domain, 'UUID' => uuid }
      response = @connection.create_tags(@subject.id, tags)
      raise "failed" unless response.status == 200
      return self
    end


    def update_root_volume_tags
      log "updating root volume tags"
      tags = { 'Name' => "#{name}-root", 'UUID' => uuid }
      response = @connection.create_tags(@subject.volumes.first.id, tags)
      raise "failed" unless response.status == 200
      return self
    end


    def update_volumes
      update_root_volume_tags

      @options[:volumes].each do |options|
        options[:availability_zone] = @subject.availability_zone
        Volume.new(options).attach(@subject.id)
      end
    end


    def update_dns
      return unless @options[:domain]
      log "updating dns zone"
      
      unless dns_zone
        log "dns zone does not exist"
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

      dns_zone.records.create(:name => fqdn, :type => 'CNAME', :value => @subject.dns_name, :ttl => 5)
      log "#{fqdn} -> #{@subject.dns_name}"
      return self
    end


    def remove_dns
      return unless @options[:domain]
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


  private


    def wait_for_state_transitions
      return unless @subject
      return unless %w(stopping pending).include? @subject.state
      log "waiting for state transition from '#{@subject.state}' to complete"
      wait_for { @subject.state != 'pending' }
      wait_for { @subject.state != 'stopping' }
    end


    def dns_connection
      @dns_connection ||= Fog::DNS.new(:provider => :aws)
    end


    def dns_zone
      @dns_zone ||= dns_connection.zones.find { |zone| zone.domain == domain }
    end

    def dns_record
      dns_zone.records.find { |record| record.name == fqdn }
    end      

    def dns_record_matches?(record)
      !!record and record.value.any? { |dns_name| dns_name == @subject.dns_name }
    end

  end
end