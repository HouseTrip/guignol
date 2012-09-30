
require 'guignol/commands/base'
require 'guignol/models/instance'

Guignol::Shell.class_eval do
  desc 'create PATTERNS', 'Create instances matching PATTERNS and their volumes (unless they exist) then run start'
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

