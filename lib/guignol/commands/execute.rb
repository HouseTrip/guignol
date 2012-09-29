
require 'guignol/commands/base'
require 'guignol/models/instance'

module Guignol::Commands
  class Execute < Base
    
    ensure_args "--execute", "--aws-key"
    
    def run_on_server(name, config)
      instance = Guignol::Models::Instance.new(name, config)
      instance.subject.ssh(arg_val("--execute"), :keys => arg_val("--aws-key"))
    end

    def self.short_usage
      ["<regexps>", "Execute command on server"]
    end
  end
end

