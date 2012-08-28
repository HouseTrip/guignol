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


require 'pathname'
require 'parallel'
require 'guignol/array/collect_key'

module Guignol::Commands
  class Base
    class Error < Exception; end
    
    def self.ensure_args(*args)
      self.class_variable_set(:@@ensure_args, args.flatten)
    end
    
    NAMED_ARG = /^--/

    def initialize(*argv)
      @argv = argv.flatten
      @all_configs = load_config_files
      check_config_consistency
      @configs = servers.map { |pattern| 
        @all_configs.select { |config|
          config[:name] =~ /#{pattern}/
        }
      }.flatten.uniq
      ensure_args
    end

    def run
      before_run or return if respond_to?(:before_run)

      Parallel.each(@configs, :in_threads => @configs.size) do |config|
        run_on_server(config)
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
  
    def configs
      @all_configs
    end

    def confirm(message)
      return true unless $stdin.tty?
      $stdout.print "#{message}? [y/N] "
      $stdout.flush
      answer = $stdin.gets
      return answer.strip =~ /y/i
    end
    
    def ensure_args
      return unless self.class.class_variable_defined?(:@@ensure_args)
 
      self.class.class_variable_get(:@@ensure_args).each do |req_arg|
        raise Error.new("required argument #{req_arg} not found") unless args.include?(req_arg)
      end
    end

  private
  
    def _servers
      @argv - args
    end
    
    def _args
      @argv.dup.drop_while do |arg|
        (arg =~ NAMED_ARG).nil?
      end
    end
    
    def next_arg(arg_name)
      index = args.index(arg_name)
      arg_at = args[index + 1]
      return nil if arg_at =~ NAMED_ARG
      arg_at
    end

    # Read & return the first available config.
    def load_config_files
      [
        Pathname.new(ENV['GUIGNOL_YML'] || '/var/nonexistent'),
        Pathname.new('guignol.yml'),
        Pathname.new('config/guignol.yml'),
        Pathname.new(ENV['HOME']).join('.guignol.yml')
      ].each do |pathname|
        next unless pathname.exist?
         return YAML.load(pathname.read)
      end
      return {}
    end

    def check_config_consistency
      errors = []
      errors << "Instance config lacks :name" unless @all_configs.collect_key(:name).all?
      errors << "Instance config lacks :uuid" unless @all_configs.collect_key(:uuid).all?
      errors << "Volume config lacks :uuid"   unless @all_configs.collect_key(:volumes).collect_key(:uuid)
      raise errors.join(', ') if errors.any?
    end
  end
end
