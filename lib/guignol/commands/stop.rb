require 'guignol/commands/base'
require 'guignol/instance'

module Guignol::Commands
  class Stop < Base
    def before_run
      return true if @configs.empty?
      names = @configs.map { |config| config[:name] }.join(", ")
      confirm "Are you sure you want to stop servers #{names}"
    end

    def run_on_server(config)
      Guignol::Instance.new(config).stop
    end
  end
end

