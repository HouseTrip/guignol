require 'guignol/commands/create'
require 'guignol/commands/kill'
require 'guignol/commands/start'
require 'guignol/commands/stop'
require 'guignol/commands/help'
require 'guignol/commands/list'
require 'guignol/commands/uuid'

module Guignol::Commands
  Map = {
    'create'     => Guignol::Commands::Create,
    'kill'       => Guignol::Commands::Kill,
    'start'      => Guignol::Commands::Start,
    'stop'       => Guignol::Commands::Stop,
    'help'       => Guignol::Commands::Help,
    'list'       => Guignol::Commands::List,
    'uuid'       => Guignol::Commands::UUID,
  }
end