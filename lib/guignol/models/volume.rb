# Copyright (c) 2012, HouseTrip SA.
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met: 
# 
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer. 
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution. 
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# 
# The views and conclusions contained in the software and documentation are those
# of the authors and should not be interpreted as representing official policies, 
# either expressed or implied, of the authors.

require 'fog'
require 'active_support/core_ext/hash/slice'
require 'guignol'
require 'guignol/models/base'


module Guignol::Models
  class Volume < Base
    class Error < Exception; end


    def availability_zone
      subject && subject.availability_zone
    end


    def create
      log "volume already exists" and return self if exist?

      log "creating volume"
      create_options = Guignol::DefaultVolumeOptions.merge options.slice(:availability_zone, :size, :snapshot, :delete_on_termination)
      set_subject connection.volumes.create(create_options)
      update_tags

      wait_for_state 'available'
      return self
    rescue Exception => e
      log "error while creating (#{e.class.name})"
      destroy
      raise
    end


    def destroy
      return self unless exist?

      log "destroying volume"
      subject.destroy
      wait_for_state 'deleted'
      # FIXME: remove tags here

      set_subject nil
      return self
    end


    def attach(server_id)
      exist? or create
      subject.reload
      if subject.server_id == server_id
        if subject.device == options[:dev]
          log "volume already attached"
          return
        else
          log "error: volume attached to device #{subject.device} instead of options[:dev]"
          raise Error.new('already attached')
        end
      end
      response = connection.attach_volume(server_id, subject.id, options[:dev])
      response.status == 200 or raise Error.new('failed to attach volume')
      update_tags
      return self
    end


    private


    def find_subject
      connection.volumes.
        select { |s| %w(in-use available).include?(s.state) }.
        find { |s| s.tags['UUID'] == uuid }
    end


    def update_tags
      log "updating tags"
      tags = { 'Name' => name, 'UUID' => uuid }
      response = connection.create_tags(subject.id, tags)
      unless response.status == 200
        log "updating tags failed"
        destroy and raise Error.new('updating tags failed')
      end
    end


  end
end