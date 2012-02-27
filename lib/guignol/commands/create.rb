require 'guignol/commands/base'
require 'guignol/instance'

module Guignol::Commands
  class Create < Base
    def run_on_server(config)
      Guignol::Instance.new(config).create
    end
  end
end

