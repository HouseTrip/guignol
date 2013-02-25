
require 'fog'
require 'active_support/core_ext/hash/slice'
require 'active_support/core_ext/hash/reverse_merge'
require 'guignol/configuration'

module Guignol
  # Pool Fog connections to minimize latency
  module Connection
    def self.get(options)
      @connections ||= {}
      @connections[options] ||= Fog::Compute.new(credentials.merge options)
    end


    private


    # Find and return credentials
    def self.credentials
      if ENV['AWS_SECRET_KEY_ID'] && ENV['AWS_SECRET_ACCESS_KEY']
        {
          :aws_access_key_id     => ENV['AWS_SECRET_KEY_ID'],
          :aws_secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
        }
      else
        Guignol.configuration.slice(:aws_access_key_id, :aws_secret_access_key)
      end
    end


  end
end