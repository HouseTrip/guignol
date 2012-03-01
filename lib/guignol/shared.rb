require 'guignol/tty_spinner'

module Guignol
  module Shared


    def log message
      stamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')
      $stderr.write("[#{stamp}] #{name}: #{message}\n")
      $stderr.flush
      true
    end


    def subject_name
      self.class.name.gsub(/.*:/,'').downcase
    end


    def wait_for_state(*states)
      @subject or raise "#{subject_name} doesn't exist"
      original_state = @subject.state
      unless states.include?(original_state)
        log "waiting for #{subject_name} to become #{states.join(' or ')}..."
        wait_for do
          if @subject.state != original_state
            log "#{subject_name} now #{@subject.state}"
            original_state = @subject.state
          end
          states.include?(@subject.state)
        end
      end
    end


    def wait_for(&block)
      return unless @subject
      @subject.wait_for { TtySpinner.spin! ; block.call }
    end

    def confirm(message)
      puts "#{message} [y/n]"
      $stdin.gets =~ /^y$/i
    end

    def require_options(*required_options)
      required_options.each do |required_option|
        next if @options.include?(required_option)
        raise "option '#{required_option}' is mandatory for each #{subject_name}"
      end
    end
  end
end