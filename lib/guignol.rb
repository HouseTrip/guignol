
require 'core_ext/array/collect_key'
require 'core_ext/hash/map_to_hash'
require 'guignol/logger'
require 'guignol/configuration'
require 'guignol/env'

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