require 'guignol/commands/base'
require 'uuidtools'

module Guignol::Commands
  class UUID
    def run
      puts UUIDTools::UUID.random_create.to_s.upcase
    end

    def self.short_usage
      ["", "Return a brand new UUID"]
    end
  end
end
