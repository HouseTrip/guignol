
require 'guignol/commands/base'
require 'guignol/models/instance'

module Guignol::Commands
  class Help
    def initialize(*argv)
      if help_for = argv.shift
        @command_class = Guignol::Commands::Map[help_for]
        @command_class.nil? and raise "no such command '#{help_for}'"
      end
    end

    def run
      if @command_class.respond_to?(:long_usage)
        puts @command_class.long_usage
      else
        usage
      end
    end

    def usage
      puts "usage: guignol <command> [options] [patterns]"
      puts "manipulate EC2 instances from your command line."
      puts
      puts "The commands are:"
      command_table =
        Guignol::Commands::CommandList.map { |command_name, command_class|
          usage = command_class.short_usage
           [command_name] + usage
        }
      puts format_table(command_table, :sep => "  ")
    end

    def self.short_usage
      ["", "You're reading it !"]
    end

  private

    # Format a text table from an array of arrays. Rows separated by +sep+.
    def format_table(table, options={})
      sep = options.delete(:sep) || " | "
      columns = table.map { |row| row.size }.max
      widths = table.reduce([0] * columns) { |memo,row| row.map(&:size).zip(memo).map(&:max) }
      format = widths.map { |width| "%-#{width}s" }.join(sep)
      table.map { |row| format % row }.join("\n")
    end
  end
end

