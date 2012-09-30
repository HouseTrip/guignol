
require 'guignol/configuration'
require 'guignol/commands/base'
require 'uuidtools'
require 'yaml'


module Guignol::Commands
  class Clone < Base
    def initialize(source_name, target_name)
      super()
      @source_name = source_name
      @target_name = target_name

      @source_config = Guignol.configuration[source_name]
      unless @source_config
        raise "machine '#{source_name}' is unknown"
      end
    end


    def run
      new_config = @source_config.map_to_hash(:deep => true) do |key,value|
        value = value.gsub(/#{@source_name}/, @target_name) if value.kind_of?(String)
        key   = key.gsub(  /#{@source_name}/, @target_name) if key.kind_of?(String)

        case key
        when :uuid
          [key, UUIDTools::UUID.random_create.to_s.upcase]
        else
          [key, value]
        end
      end

      $stdout.puts({@target_name => new_config}.to_yaml)
    end
  end
end
