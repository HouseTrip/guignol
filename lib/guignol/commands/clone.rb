
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
        case key
        when :uuid
          UUIDTools::UUID.random_create.to_s.upcase
        when :name
          value.sub(/#{@source_name}/, @target_name)
        else
          value
        end
      end
      # binding.pry
      $stdout.puts [new_config].to_yaml
    end


    def self.short_usage
      ["<name> <new-name>", "Print YAML for a new machine that mimics another."]
    end
  end
end
