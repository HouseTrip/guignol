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

require 'guignol/tty_spinner'

module Guignol
  module Shared

    private

    def log(message)
      Guignol.logger.info("#{name}: #{message}")
      Thread.pass
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