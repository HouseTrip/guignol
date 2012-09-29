
require 'guignol/commands/base'
require 'guignol/models/instance'

module Guignol::Commands
  class Start < Base
    def run_on_server(name, config)
      Guignol::Models::Instance.new(name, config).start
    end

    def self.short_usage
      ["<regexps>", "Start instances (unless they're running) and setup DNS"]
    end
  end
end

