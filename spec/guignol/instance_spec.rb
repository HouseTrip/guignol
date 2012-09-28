require 'spec_helper'
require 'guignol/models/instance'

describe Guignol::Models::Instance do
  subject { described_class.new(name, options) }

  let(:name) { "foobar" }
  let(:options) {{
    :uuid => '948DB8E9-A356-4F66-8857-165FBDF5A71F'
  }}

  before(:each) do
    # connection = stub(:servers => [])
    # Fog::Compute.stub(:new).and_return(connection)
  end

  describe '#initialize' do
    it 'should require :uuid' do
      options.delete :uuid
      expect { subject }.to raise_error
    end

    it 'should require a name' do
      name.replace ""
      expect { subject }.to raise_error
    end

    it 'should pass with minimal options' do
      subject
    end
  end


  shared_examples_for 'server setup' do
    it 'set server tags'
    it 'configures DNS properly'
  end


  describe '#create' do
    it 'should pass with minimal options' do
      subject.create
    end

    it 'reuses existing volumes'
    it 'fails when existing volumes are in different zones'

    it 'starts up the server'

    it_should_behave_like 'server setup'
  end


  describe '#start' do
    it_should_behave_like 'server setup'

    it 'returns when the server does not exist' do
      subject.start
    end

    it 'returns with a server marked as "running"'

  end


  describe '#destroy' do
    it 'should pass with minimal options' do
      subject.destroy
    end
  end
end