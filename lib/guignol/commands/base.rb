

require 'guignol'
require 'guignol/configuration'
require 'pathname'
require 'parallel'
require 'core_ext/array/collect_key'

module Guignol::Commands
  class Base
    Error = Class.new(Exception)
    NAMED_ARG_RE = /^--/

    module ClassMethods
      def ensure_args(*args)
        @ensure_args ||= []
        return @ensure_args if args.empty?
        @ensure_args = args.flatten
      end
    end
    extend ClassMethods


    def initialize(*argv)
      @argv = argv.flatten
      @configs = Guignol.configuration.delete_if { |name,config|
        servers.none? { |pattern| name.to_s =~ /#{pattern}/ }
      }
      ensure_args
    end

    def run
      before_run or return if respond_to?(:before_run)

      Parallel.each(@configs, :in_threads => @configs.size) do |name,config|
        run_on_server(name, config)
      end
    end

    def servers
      @servers ||= _servers
    end
    
    def args
      @args ||= _args
    end
    
    def arg_val(arg_name)
      return nil unless args.include?(arg_name)
      next_arg(arg_name)
    end
    
    def arg?(arg_name)
      args.include?(arg_name)
    end
    

    protected

    attr :configs

    def confirm(message)
      return true unless $stdin.tty?
      $stdout.print "#{message}? [y/N] "
      $stdout.flush
      answer = $stdin.gets
      return answer.strip =~ /y/i
    end
    
    def ensure_args
      self.class.ensure_args.each do |req_arg|
        raise Error.new("required argument #{req_arg} not found") unless args.include?(req_arg)
      end
    end

  private
  
    def _servers
      @argv - args
    end
    
    def _args
      @argv.dup.drop_while do |arg|
        (arg =~ NAMED_ARG_RE).nil?
      end
    end
    
    def next_arg(arg_name)
      index = args.index(arg_name)
      arg_at = args[index + 1]
      return nil if arg_at =~ NAMED_ARG_RE
      arg_at
    end
  end
end
