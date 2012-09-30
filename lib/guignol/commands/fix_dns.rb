
require 'guignol/commands/base'
require 'guignol/models/instance'

Guignol::Shell.class_eval do
  desc 'fixdns [PATTERNS]', 'Make sure the DNS mappings are correct for servers matching PATTERNS'
  def fixdns(*patterns)
    patterns.push('.*') if patterns.empty?
    Guignol::Commands::FixDNS.new(patterns).run
  end
end


module Guignol::Commands
  class FixDNS < Base
    def run_on_server(instance, options = {})
      instance.update_dns
    end
  end
end

