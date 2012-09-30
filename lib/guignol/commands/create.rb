
require 'guignol/commands/base'
require 'guignol/models/instance'

Guignol::Shell.class_eval do
  desc 'create PATTERNS', 'Create and start all instances matching PATTERNS and their volumes'
  def create(*patterns)
    if patterns.empty?
      raise Thor::Error.new('You must specify at least one PATTERN.')
    end
    Guignol::Commands::Create.new(patterns).run
  end
end


module Guignol::Commands
  class Create < Base
    def run_on_server(instance, options = {})
      instance.create
    end
  end
end

