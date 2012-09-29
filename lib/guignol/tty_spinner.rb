
require 'singleton'
require 'guignol'

module Guignol
  class TtySpinner
    include Singleton

    Chars = ['/','|','\\', '-']

    def initialize
      @state = 0
    end

    def spin!
      if $stderr.tty? && !Guignol.env.test?
        $stderr.write(Chars[@state % Chars.size] + "\r")
        $stderr.flush
        @state += 1
      end
      Thread.pass
    end

    def self.spin!
      instance.spin!
    end

  end
end