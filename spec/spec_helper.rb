require 'rspec'
require 'rspec/mocks'
require 'fog'

Fog.mock!

ENV['GUIGNOL_ENV'] = 'test'
ENV['GUIGNOL_LOG'] = '/dev/null'
ENV['AWS_SECRET_KEY_ID'] = 'aws-key-id'
ENV['AWS_SECRET_ACCESS_KEY'] = 'aws-password'

RSpec.configure do |config|
  config.before do
    Fog::Mock.reset
  end
end
