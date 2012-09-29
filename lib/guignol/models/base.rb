
require 'guignol/connection'
require 'guignol/tty_spinner'

module Guignol::Models
  class Base
    # The wrapped instance, volume, etc we're manipulating
    attr :subject
    attr :options
    attr :connection
    attr :name

    def initialize(name, options)
      @name    = name
      @options = default_options.merge(options)
      require_name!
      require_options! :uuid
      connection_options = Guignol::DefaultConnectionOptions.merge @options.slice(:region)

      @connection = Guignol::Connection.get(connection_options)
      @subject = find_subject
    end


    def exist?
      !!@subject
    end
    alias_method :exists?, :exist?


    def uuid
      @options[:uuid]
    end


    def state
      @subject and @subject.state or 'nonexistent'
    end


    protected


    def set_subject(subject)
      @subject = subject
    end


    def reload
      @subject = find_subject
    end


    def find_subject
      raise 'Define me in a subclass'
    end


    Interval = 200e-3
    Timeout  = 300


    def default_options
      {}
    end

    def log(message, options={})
      Guignol.logger.info("#{name}: #{message}")
      if e = options[:error]
        Guignol.logger.info e.class.name
        Guignol.logger.info e.message
        e.backtrace.each { |line| Guignol.logger.debug line }
      end
      Thread.pass
      true
    end


    def subject_name
      self.class.name.gsub(/.*:/,'').downcase
    end


    # wait until the subject is in one of +states+
    def wait_for_state(*states)
      exist? or raise "#{subject_name} doesn't exist"
      original_state = state
      return if states.include?(original_state)
      log "waiting for #{subject_name} to become #{states.join(' or ')}..."
      Fog.wait_for(Timeout,Interval) do
        Guignol::TtySpinner.spin!
        reload
        if state != original_state
          log "#{subject_name} now #{state}"
          original_state = state
        end
        states.include?(state)
      end
    end


    def wait_for(&block)
      return unless @subject
      @subject.wait_for(Timeout,Interval) { Guignol::TtySpinner.spin! ; block.call }
    end


    def confirm(message)
      puts "#{message} [y/n]"
      $stdin.gets =~ /^y$/i
    end

    def require_name!
      return unless @name.nil? || @name =~ /^\s*$/
      raise "Name cannot be empty or blank"
    end

    def require_options!(*required_options)
      required_options.each do |required_option|
        next if @options.include?(required_option)
        raise "option '#{required_option}' is mandatory for each #{subject_name}"
      end
    end
  end
end