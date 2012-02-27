require 'singleton'

module Guignol
  class TtySpinner
    include Singleton

    Chars = ['/','|','\\', '-']

    def initialize
      @state = 0
    end

    def spin!
      $stderr.write(Chars[@state % Chars.size] + "\r")
      $stderr.flush
      @state += 1
      Thread.pass
    end

    def self.spin!
      instance.spin!
    end

  end
end