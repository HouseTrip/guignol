require 'thor'
require 'pathname'
require 'parallel'
require 'guignol'
require 'guignol/configuration'
require 'guignol/models/instance'
require 'core_ext/array/collect_key'

module Guignol::Commands
  class Base

    def initialize(patterns, options = {})
      @configs = select_configs(patterns)
      @options = options
    end

    # Run the block for each server in +configs+ (in parallel).
    def run
      before_run(@configs, @options) or return
      results = {}

      Parallel.each(@configs, parallel_options) do |name,config|
        instance = Guignol::Models::Instance.new(name, config)
        results[name] = run_on_server(instance, @options)
      end

      after_run(results, @options)
    end


    protected

    # Override in subclasses
    def before_run(configs, options) ; true ; end

    # Override in subclasses
    def after_run(data, options) ; true ; end


    def shell
      Guignol::Shell.shared_shell
    end


    def synchronize
      (@mutex ||= Mutex.new).synchronize do
        yield
      end
    end

    private

    def parallel_options
      if RUBY_VERSION >= '1.9.3'
        # 1.9.3 has bugs with Excon / SSL connections
        { :in_threads => 0 }
      else
        { :in_threads => @configs.size }
      end
    end

    # Put all the servers matching one of the +names+ in +configs+.
    def select_configs(patterns)
      patterns = patterns.map { |pattern| 
        pattern.kind_of?(String) ? Regexp.new(pattern) : pattern
      }
      Guignol.configuration.delete_if { |name,config| 
        patterns.none? { |pattern| name.to_s =~ pattern }
      }
    end

  end
end
