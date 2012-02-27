require 'pathname'
require 'parallel'
require 'awesome_print'
require 'guignol/instance'
require 'guignol/array/collect_key'

module Guignol::Commands
  class Base

    def initialize(patterns)
      @all_configs = load_config_files
      check_config_consistency
      @configs = patterns.map { |pattern| 
        @all_configs.select { |config|
          config[:name] =~ /#{pattern}/
        }
      }.flatten.uniq
    end

    def run
      before_run or return
      Parallel.each(@configs) do |config|
        run_on_server(config)
      end
    end

  protected

    def confirm(message)
      $stdout.print "#{message}? [y/N] "
      $stdout.flush
      answer = $stdin.gets
      return answer.strip =~ /y/i
    end

    # Override in subclasses to do the heavy lifting
    def before_run
      return true
    end

  private

    # Read & return the first available config.
    def load_config_files
      [
        Pathname.new(ENV['GUIGNOL_YML'] || '/var/nonexistent'),
        Pathname.new('guignol.yml'),
        Pathname.new('config/guignol.yml'),
        Pathname.new(ENV['HOME']).join('.guignol.yml')
      ].each do |pathname|
        next unless pathname.exist?
         return YAML.load(pathname.read)
      end
      return {}
    end

    def check_config_consistency
      errors = []
      errors << "Instance config lacks :name" unless @all_configs.collect_key(:name).all?
      errors << "Instance config lacks :uuid" unless @all_configs.collect_key(:uuid).all?
      errors << "Volume config lacks :uuid"   unless @all_configs.collect_key(:volumes).collect_key(:uuid)
      raise errors.join(', ') if errors.any?
    end
  end
end
