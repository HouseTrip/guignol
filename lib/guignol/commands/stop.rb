
require 'guignol/commands/base'
require 'guignol/models/instance'

module Guignol::Commands
  class Stop < Base
    def before_run
      return true if configs.empty?
      names = configs.keys.join(", ")
      confirm "Are you sure you want to stop servers #{names}"
    end

    def run_on_server(name, config)
      Guignol::Models::Instance.new(name, config).stop
    end

    def self.short_usage
      ["<regexps>", "Stop instances (if they're running) and remove DNS"]
    end
  end
end

