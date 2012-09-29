
require 'guignol/commands/base'
require 'guignol/models/instance'

module Guignol::Commands
  class Kill < Base
    def before_run
      return true if configs.empty?
      names = configs.keys.join(", ")
      confirm "Are you sure you want to destroy servers #{names}"
    end

    def run_on_server(config)
      Guignol::Models::Instance.new(config).destroy
    end

    def self.short_usage
      ["<regexps>", "Destroy instances (if they exist)"]
    end
  end
end

