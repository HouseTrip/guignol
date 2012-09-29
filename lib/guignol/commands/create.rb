
require 'guignol/commands/base'
require 'guignol/models/instance'

module Guignol::Commands
  class Create < Base
    def run_on_server(config)
      Guignol::Models::Instance.new(name, config).create
    end

    def self.short_usage
      ["<regexps>", "Create instances and volumes (unless they exist) then run start"]
    end
  end
end

