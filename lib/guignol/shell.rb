require 'thor'

module Guignol
  class Shell < Thor
    def help(*args)
      shell.say
      shell.say "Guignol -- manipulate EC2 instances from your command line.", :cyan
      shell.say
      super
    end

    def self.start
      super(ARGV, :shell => shared_shell)
    end

    def self.shared_shell
      @shared_shell ||= if $stdout.tty?
        Thor::Shell::Color.new
      else
        Thor::Shell::Basic.new
      end
    end

    def self.exit_on_failure?
      true
    end


    def self.add_force_option
      method_option :force,
        :aliases => %w(-f), :type => :boolean, :default => false,
        :desc => 'Do not ask for confirmation'
    end
  end
end


require 'guignol/commands/create'
require 'guignol/commands/kill'
require 'guignol/commands/start'
require 'guignol/commands/stop'
require 'guignol/commands/list'
require 'guignol/commands/uuid'
require 'guignol/commands/fix_dns'
require 'guignol/commands/clone'
require 'guignol/commands/execute'
