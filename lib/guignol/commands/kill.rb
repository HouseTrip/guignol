
require 'guignol/commands/base'
require 'guignol/models/instance'

Guignol::Shell.class_eval do
  desc 'kill PATTERNS', 'Terminate servers matching PATTERNS'
  def kill(*patterns)
    if patterns.empty?
      raise Thor::Error.new('You must specify at least one PATTERN.')
    end
    Guignol::Commands::Kill.new(patterns).run
  end
end


module Guignol::Commands
  class Kill < Base

    def before_run(configs)
      return true if configs.empty?
      names = configs.keys.join(", ")
      shell.yes? "Are you sure you want to destroy servers #{names}? [y/N]", :cyan
    end

    def run_on_server(instance, options = {})
      instance.destroy
    end
  end
end

