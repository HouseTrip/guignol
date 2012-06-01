require 'rspec'
require 'rspec/mocks'
require 'fog'

Fog.mock!

RSpec.configure do |config|
  config.before do
    [$stderr, $stdout, $stdin].each do |io|
      # io.stub(:tty? => false)
    end
  end
end