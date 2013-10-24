require 'spec_helper'
require 'guignol/models/instance'

describe Guignol::Models::Instance do
  subject { described_class.new(name, options) }

  let(:name) { "foobar" }
  let(:options) {{
    :uuid => '948DB8E9-A356-4F66-8857-165FBDF5A71F'
  }}

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
      expect { subject }.to_not raise_error
    end

    it 'parses ERB in user data' do
      options[:foo] = 'bar'
      options[:user_data] = "foo=<%= foo %>,<%= name %>"
      subject.options[:user_data].should == 'foo=bar,foobar'
    end
  end

  describe '#create' do
    it 'set server tags' do
      expected_tags = {'Name' => name, 'UUID' => options[:uuid]}

      subject.connection.should_receive(:create_tags)
        .with(anything, {'Domain' => nil}.merge(expected_tags))
        .and_return(double(:status => 200))

      subject.create
    end

    it "configures DNS properly" do
      subject.should_receive(:update_dns)
      subject.create
    end

    it 'should pass with minimal options' do
      expect { subject.create }.to_not raise_error
    end

    it 'does not break when providing an availibity zone' do
      instance = described_class.new(name, options.merge(:availability_zone => 'eu-west-1c'))
      expect { instance.create }.to_not raise_error
    end

    it 'does not allow an availability zone that does not match the region' do
      instance = described_class.new(name, options.merge(:availability_zone => 'us-west-1a'))
      expect { instance.create }.to raise_error('availability zone us-west-1a is not in the defined region eu-west-1')
    end

    it 'requires existing volumes to live in a given availability zone'
    it 'reuses existing volumes'
    it 'fails when existing volumes are in different zones'

    it 'starts up the server'
  end


  describe "#id" do
    it "returns nil when there is no 'subject' (server)" do
      instance = Guignol::Models::Instance.new(name, options)
      instance.stub(:subject).and_return(nil)

      instance.id.should be_nil
    end

    it "returns the id when 'subject' has no id" do
      instance = Guignol::Models::Instance.new(name, options)
      instance.stub(:subject).and_return(double)

      instance.id.should be_nil
    end

    it "returns the id when 'subject' exists and has an id" do
      instance = Guignol::Models::Instance.new(name, options)
      instance.stub(:subject).and_return(double(:id => 'i-123456'))

      instance.id.should == 'i-123456'
    end
  end

  describe '#start' do

    it 'returns when the server does not exist' do
      instance = Guignol::Models::Instance.new(name, options)
      instance.stub(:subject).and_return(nil)

      instance.start.should be_nil
    end

    it 'returns with a server marked as "running"'
  end


  describe '#destroy' do
    it 'should pass with minimal options' do
      expect { subject.destroy }.to_not raise_error
    end
  end
end
