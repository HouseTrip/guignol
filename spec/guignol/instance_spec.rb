require 'guignol/instance'

describe Guignol::Instance do
  subject { Guignol::Instance.new(options) }

  let(:options) {{
    :name => 'foobar',
    :uuid => '948DB8E9-A356-4F66-8857-165FBDF5A71F'
  }}

  before(:each) do
    connection = stub(:servers => [])
    Fog::Compute.stub(:new).and_return(connection)
  end

  describe '#initialize' do
    it 'should require :uuid' do
      options.delete :uuid
      expect { subject }.to raise_error
    end

    it 'should require :name' do
      options.delete :name
      expect { subject }.to raise_error
    end

    it 'should pass with minimal options' do
      subject
    end
  end
end