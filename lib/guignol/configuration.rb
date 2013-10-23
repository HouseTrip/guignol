require 'pathname'
require 'active_support'
require 'active_support/core_ext/enumerable'
require 'guignol'

module Guignol
  module Configuration

    def configuration
      @configuration ||= load_config_file
    end

    private

    def config_file_path
      @config_file_path ||= [
        Pathname.new(ENV['GUIGNOL_YML'] || '/var/nonexistent'),
        Pathname.new('guignol.yml'),
        Pathname.new('config/guignol.yml'),
        Pathname.new(ENV['HOME']).join('.guignol.yml')
      ].find(&:exist?)
    end

    # Load the config hash for the file, converting old (v0.2.0) Yaml config files.
    def load_config_file
      return {} if config_file_path.nil?
      data = YAML.load(config_file_path.read)
      return data unless data.kind_of?(Array)

      # Convert the toplevel array to a hash. Same for arrays of volumes.
      Guignol.logger.warn "Configuration file '#{config_file_path}' uses the old array format. Trying to load it."
      raise "Instance config lacks :name" unless data.collect_key(:name).all?
      result = data.index_by { |item| item.delete(:name) }
      result.each_pair do |name, config|
        next unless config[:volumes]
        raise "Volume config lacks :name" unless config[:volumes].collect_key(:name).all?
        config[:volumes] = config[:volumes].index_by { |item| item.delete(:name) }
      end

      return result
    end

    Guignol.extend(self)
  end
end
