# Copyright (c) 2012, HouseTrip SA.
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met: 
# 
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer. 
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution. 
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# 
# The views and conclusions contained in the software and documentation are those
# of the authors and should not be interpreted as representing official policies, 
# either expressed or implied, of the authors.

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

