
require 'guignol/commands/create'
require 'guignol/commands/kill'
require 'guignol/commands/start'
require 'guignol/commands/stop'
require 'guignol/commands/help'
require 'guignol/commands/list'
require 'guignol/commands/uuid'
require 'guignol/commands/fix_dns'
require 'guignol/commands/clone'
require 'guignol/commands/execute'

module Guignol::Commands
  CommandList = [
    ['create',    Guignol::Commands::Create ],
    ['kill',      Guignol::Commands::Kill   ],  
    ['start',     Guignol::Commands::Start  ],  
    ['stop',      Guignol::Commands::Stop   ],  
    ['help',      Guignol::Commands::Help   ],  
    ['list',      Guignol::Commands::List   ],  
    ['uuid',      Guignol::Commands::UUID   ],  
    ['fixdns',    Guignol::Commands::FixDNS ],      
    ['clone',     Guignol::Commands::Clone  ],
    ['execute',   Guignol::Commands::Execute  ],    
  ]
  Map = Hash[CommandList]
end