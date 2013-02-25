
require 'guignol/commands/base'
require 'guignol/models/instance'

Guignol::Shell.class_eval do
  desc 'dns [PATTERNS]', 'Prints the DNS mappings for servers matching PATTERNS'
  def dns(*patterns)
    patterns.push('.*') if patterns.empty?
    Guignol::Commands::DNS.new(patterns).run
  end
end


module Guignol::Commands
  class DNS < Base
    def run_on_server(instance, options = {})
      synchronize do
        shell.say instance.name.ljust(@max_width + 1)
        shell.say instance.dns_name
      end
    end

    def before_run(configs, options = {})
      @max_width = configs.keys.map(&:size).max
    end
  end
end

