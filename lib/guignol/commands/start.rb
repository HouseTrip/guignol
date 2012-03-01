require 'guignol/commands/base'
require 'guignol/instance'

module Guignol::Commands
  class Start < Base
    def run_on_server(config)
      Guignol::Instance.new(config).start
    end

    def self.short_usage
      ["<regexps>", "Start instances (unless they're running) and setup DNS"]
    end
  end
end

