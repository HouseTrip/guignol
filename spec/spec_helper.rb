require 'rspec'
require 'rspec/mocks'
require 'fog'

Fog.mock!

ENV['GUIGNOL_ENV'] = 'test'
ENV['GUIGNOL_LOG'] = '/dev/null'

RSpec.configure do |config|
  # nib
end