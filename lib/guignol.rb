module Guignol
    DefaultConnectionOptions = {
      :provider  => :aws,
      :region    => 'eu-west-1'
    }
    DefaultServerOptions = {
      :flavor_id => 't1.micro',
      :volumes   => []
    }
    DefaultVolumeOptions = {}
end