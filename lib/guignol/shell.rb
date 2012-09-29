
require 'term/ansicolor'
require 'guignol/commands'

module Guignol
  class Shell
    include Singleton

    def execute(command_name, *argv)
      command_name ||= 'help'
      unless command = Commands::Map[command_name]
        Commands::Help.new.run
        die "no such command '#{command_name}'."
      end
      command.new(*argv).run
      exit 0
    end

    def die(message)
      puts Term::ANSIColor.red("fatal: #{message}")
      exit 1
    end
  end
end
