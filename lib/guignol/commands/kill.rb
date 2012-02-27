require 'guignol/commands/base'
require 'guignol/instance'

module Guignol::Commands
  class Kill < Base
    def before_run
      return true if @configs.empty?
      names = @configs.map { |config| config[:name] }.join(", ")
      confirm "Are you sure you want to destroy servers #{names}"
    end

    def run_on_server(config)
      Guignol::Instance.new(config).destroy
    end
  end
end

