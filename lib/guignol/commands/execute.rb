require 'guignol/commands/base'

Guignol::Shell.class_eval do
  desc 'execute COMMAND', 'Execute a command on servers'
  method_option :on,
    :banner => 'PATTERNS',
    :type => :array, :default => ['.*'],
    :desc => 'A list of regexps matching servers on which to run'
  method_option :verbose,
    :aliases => %w(-v), :type => :boolean, :default => false,
    :desc => 'Output the command output to the local terminal'
  method_option :aws_key,
    :aliases => %w(-k), :type => :string,
    :desc => 'Path the the SSH key file to use to connect'
  method_option :user,
    :aliases => %w(-u), :type => :string,
    :desc => 'Username used to connect (takes precedence over the name defined in the config file)'
  long_desc %Q{
    Connect to each server matching one of the PATTERNS (defaults to all
    known servers) over SSH, and run the COMMAND on them, in parallel.
  }
  def execute(*words)
    words.shift if words.first =~ /^-+$/
    command = words.join(' ')
    Guignol::Commands::Execute.
      new(options[:on], options.merge(:command => command)).
      run
  end
end

module Guignol::Commands
  class Execute < Base
    private
    def run_on_server(instance, options = {})
      if instance.state != 'running'
        print_output(instance.name, "Instance not running", :red)
        return
      end

      instance.subject.username = options[:user] if options[:user]
      results = instance.subject.ssh(options[:command], :keys => options[:aws_key])

      return unless options[:verbose]
      results.each do |result|
        print_output(instance.name, result.stderr, :yellow)
        print_output(instance.name, result.stdout, :green)
      end

    rescue Net::SSH::AuthenticationFailed => e
      print_output(instance.name, "#{e.message} (#{e.class.name})", :red)
    end

    def before_run(configs)
      @max_width = configs.keys.map(&:size).max
    end


    def print_output(name, data, color)
      synchronize do
        name_string = name.ljust(@max_width+1)
        data.split(/\r?\n/).each do |line|
          shell.say name_string, color
          shell.say line, :clear, true
        end
      end
    end
  end
end

