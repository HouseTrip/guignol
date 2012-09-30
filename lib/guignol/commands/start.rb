
require 'guignol/commands/base'
require 'guignol/models/instance'

Guignol::Shell.class_eval do
  desc 'start PATTERNS', 'Start servers matching PATTERNS (unless they are running), attach volumes, and setup DNS records'
  def start(*patterns)
    if patterns.empty?
      raise Thor::Error.new('You must specify at least one PATTERN.')
    end
    Guignol::Commands::Start.new(patterns).run
  end
end


module Guignol::Commands
  class Start < Base
    def run_on_server(instance, options = {})
      instance.start
    end
  end
end

