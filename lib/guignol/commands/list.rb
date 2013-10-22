require 'guignol/commands/base'

Guignol::Shell.class_eval do
  desc 'list [PATTERNS]', 'List the status of all known instances'
  def list(*patterns)
    patterns.push('.*') if patterns.empty?
    Guignol::Commands::List.new(patterns).run
  end
end

module Guignol::Commands
  class List < Base
    private

    def run_on_server(instance, options = {})
      synchronize do
        id = instance.id || 'unknown'
        shell.say id.ljust(@max_width)

        shell.say instance.name.ljust(@max_width + 1)
        shell.say instance.state, colorize(instance.state)
      end
    end

    def before_run(configs, options = {})
      @max_width = configs.keys.map(&:size).max
    end

    def colorize(state)
      case state
        when 'running'            then :green
        when /starting|stopping/  then :yellow
        when 'nonexistent'        then :red
      end
    end
  end
end
