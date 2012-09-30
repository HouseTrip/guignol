
require 'guignol/commands/base'
require 'guignol/models/instance'

Guignol::Shell.class_eval do
  desc 'stop PATTERNS', 'Stop all instances matching PATTERNS, and remove DNS records'
  def stop(*patterns)
    if patterns.empty?
      raise Thor::Error.new('You must specify at least one PATTERN.')
    end
    Guignol::Commands::Stop.new(patterns).run
  end
end


module Guignol::Commands
  class Stop < Base
    def before_run(configs)
      return true if configs.empty?
      names = configs.keys.join(", ")
      shell.yes? "Are you sure you want to stop servers #{names}? [y/N]", :cyan
    end

    def run_on_server(instance, options = {})
      instance.stop
    end
  end
end

