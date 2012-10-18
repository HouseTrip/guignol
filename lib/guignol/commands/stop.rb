
require 'guignol/commands/base'
require 'guignol/models/instance'

Guignol::Shell.class_eval do
  desc 'stop PATTERNS', 'Stop all instances matching PATTERNS, and remove DNS records'
  add_force_option
  def stop(*patterns)
    if patterns.empty?
      raise Thor::Error.new('You must specify at least one PATTERN.')
    end
    Guignol::Commands::Stop.new(patterns, options).run
  end
end


module Guignol::Commands
  class Stop < Base
    def before_run(configs, options = {})
      return true if configs.empty?
      return true if options[:force]
      names = configs.keys.join(", ")
      shell.yes? "Are you sure you want to stop servers #{names}? [y/N]", :cyan
    end

    def run_on_server(instance, options = {})
      instance.stop
    end
  end
end

