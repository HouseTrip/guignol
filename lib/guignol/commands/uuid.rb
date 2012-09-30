
require 'guignol/commands/base'
require 'uuidtools'

Guignol::Shell.class_eval do
  desc 'uuid [COUNT]', 'Print random UUIDs'
  method_option :count,
    :aliases => %w(-c),
    :type => :numeric, :default => 1,
    :desc => 'Number of UUIDs to print'
  def uuid
    unless options[:count].kind_of?(Fixnum) && options[:count] > 0
      raise Thor::Error.new('Count should be a positive integer')
    end
    Guignol::Commands::UUID.new.run(options[:count])
  end
end


module Guignol::Commands
  class UUID
    def run(count = 1)
      count.times do
        puts UUIDTools::UUID.random_create.to_s.upcase
      end
    end
  end
end
