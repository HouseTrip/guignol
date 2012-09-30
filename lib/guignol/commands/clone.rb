
require 'guignol/configuration'
require 'guignol/commands/base'
require 'uuidtools'
require 'yaml'


Guignol::Shell.class_eval do
  desc 'clone SOURCE', 'Print a new config similar to the server names SOURCE'
  method_option :name,
    :aliases => %w(-n),
    :type => :string, :default => 'new-server',
    :desc => 'Name to use for the new server'
  def clone(source)
    Guignol::Commands::Clone.new(source, options[:name]).run
  end
end


module Guignol::Commands
  class Clone
    def initialize(source_name, target_name)
      @source_name = source_name
      @target_name = target_name

      @source_config = Guignol.configuration[source_name]
      unless @source_config
        raise Thor::Error.new "machine '#{source_name}' is unknown"
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
