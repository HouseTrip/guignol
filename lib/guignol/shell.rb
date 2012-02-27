require 'term/ansicolor'
require 'guignol/commands'

module Guignol
  class Shell
    include Singleton

    Map = {
      'create'     => Guignol::Commands::Create,
      'kill'       => Guignol::Commands::Kill,
      'start'      => Guignol::Commands::Start,
      'stop'       => Guignol::Commands::Stop,
    }

    def execute(command_name, patterns)
      command = Map[command_name] or die "no such command '#{command_name}'."
      command.new(patterns).run
      exit 0
    end

    def die(message)
      puts Term::ANSIColor.red("fatal: #{message}")
      exit 1
    end
  end
end