require 'guignol/commands/base'
require 'guignol/instance'

module Guignol::Commands
  class List < Base
    def initialize(*argv)
      argv = ['.*'] if argv.empty?
      super(*argv)
    end

    def run_on_server(config)
      instance = Guignol::Instance.new(config)
      puts "%s: %s" % [instance.name, instance.state]
    end

    def self.short_usage
      ["[regexp]", "List known instances (matching the regexp) and their status."]
    end
  end
end

