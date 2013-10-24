require 'guignol/commands/base'

Guignol::Shell.class_eval do
  desc 'list [PATTERNS]', 'List the status of all known instances'

  option :elba, :type => :boolean, :aliases => :e
  option :with_instance_ids, :type => :boolean, :aliases => :i
  option :remote, :type => :boolean, :aliases => :r
  def list(*patterns)
    patterns.push('.*') if patterns.empty?

    if options[:remote]
      # require 'pry'; require 'pry-nav'; binding.pry
      config = YAML.load(File.open(File.join(Dir.home, '.fog')))[:default]
      client = Fog::Compute::AWS.new config.merge(:region => 'eu-west-1')

      patterns = patterns.map { |pattern|
        pattern.kind_of?(String) ? Regexp.new(pattern) : pattern
      }

      servers = client.servers.delete_if { |srv|
        patterns.none? { |pattern| srv.tags["Name"] =~ pattern  }
      }.map { |srv|
        [srv.tags["Name"], srv.id]
      }
      servers = options[:elba] ? Array[servers.collect(&:last)] : servers
      print_table servers
    else
      Guignol::Commands::List.new(patterns, options).run
    end
  end
end

module Guignol::Commands
  class List < Base
    private

    def run_on_server(instance, options = {})
      return output_elba_friendly_instance_ids(instance) if options[:elba]

      synchronize do
        if options[:with_instance_ids]
          id = "#{ instance.id || 'unknown'} "
          shell.say id.ljust(@max_width)
        end

        shell.say instance.name.ljust(@max_width + 1)
        shell.say instance.state, colorize(instance.state)
      end
    end

    def output_elba_friendly_instance_ids(instance)
      return unless instance.id
      synchronize { shell.say "#{instance.id} " }
    end

    def before_run(configs, options = {})
      @max_width = configs.keys.map(&:size).max
    end

    def colorize(state)
      case state
        when 'running'            then :green
        when /starting|stopping/  then :yellow
        when 'nonexistent'        then :red
      end
    end
  end
end
