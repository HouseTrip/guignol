
require 'guignol/commands/base'
require 'guignol/models/instance'

module Guignol::Commands
  class FixDNS < Base
    def run_on_server(name, config)
      Guignol::Models::Instance.new(name, config).update_dns
    end

    def self.short_usage
      ["<regexps>", "Make sure the DNS mappings are correct."]
    end
  end
end

