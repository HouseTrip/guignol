
require 'guignol/commands/base'
require 'guignol/models/instance'
require 'term/ansicolor'

module Guignol::Commands
  class List < Base
    def initialize(*argv)
      argv = ['.*'] if argv.empty?
      super(*argv)
    end

    def run_on_server(name, config)
      instance = Guignol::Models::Instance.new(name, config)

      puts "%-#{max_width}s %s" % [instance.name, colorize(instance.state)]
    end

    def self.short_usage
      ["[regexp]", "List known instances (matching the regexp) and their status."]
    end

  private

    def max_width
      @max_width ||= configs.keys.map(&:size).max
    end

    def colorize(state)
      case state
        when 'running'            then Term::ANSIColor.green(state)
        when /starting|stopping/  then Term::ANSIColor.yellow(state)
        when 'nonexistent'        then Term::ANSIColor.red(state)
        else state
      end
    end
  end
end

