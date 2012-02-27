require 'fog'
require 'active_support/core_ext/hash/slice'
require 'guignol'
require 'guignol/shared'


module Guignol
  class Volume
    include Shared


    def initialize(options)
      @options = options.dup
      connection_options = DefaultConnectionOptions.dup.merge @options.slice(:region)

      @connection = Fog::Compute.new(connection_options)
      @subject = @connection.volumes.
        select { |s| %w(in-use available).include?(s.state) }.
        find { |s| s.tags['UUID'] == uuid }
    end


    def exist?
      !!@subject
    end


    def name
      @options[:name]
    end


    def uuid
      @options[:uuid]
    end


    def availability_zone
      @subject && @subject.availability_zone
    end


    def create
      if exist?
        log "volume already exists"
      else
        log "creating volume"
        options = DefaultVolumeOptions.dup.merge @options.slice(:availability_zone, :size, :snapshot, :delete_on_termination)
        @subject = @connection.volumes.create(options)
        update_tags

        wait_for_state 'available'
      end
      return self
    rescue Exception => e
      log "error while creating (#{e.class.name})"
      destroy
      raise
    end


    def destroy
      if !exist?
        log "volume does not exist"
      else
        log "destroying volume"
        @subject.destroy
        wait_for_state 'deleted'
        # FIXME: remove tags here
      end
      @subject = nil
      return self
    end


    def attach(server_id)
      exist? or create
      response = @connection.attach_volume(server_id, @subject.id, @options[:dev])
      response.status == 200 or raise 'failed to attach volume'
      update_tags
    end



    def update_tags
      log "updating tags"
      tags = { 'Name' => name, 'UUID' => uuid }
      response = @connection.create_tags(@subject.id, tags)
      unless response.status == 200
        log "failed"
        destroy and return
      end
    end


  end
end