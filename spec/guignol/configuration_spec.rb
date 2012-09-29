require 'spec_helper'
require 'guignol'

describe Guignol::Configuration do
  subject { Object.new.extend(described_class) }
  let(:test_path) { Pathname.new 'tmp/test.yml' }
  let(:result) { subject.configuration }

  before do
    ENV['GUIGNOL_YML'] = test_path
    test_path.open('w') do |io|
      io.write config_data
    end
  end

  after do
    test_path.delete
  end

  shared_examples_for 'loaded config' do
    it 'should load' do
      result.should be_a_kind_of(Hash)
    end

    it 'loads volumes' do
      # require 'pry' ; require 'pry-nav' ; binding.pry
      result['john-mcfoo'][:volumes].should_not be_empty
    end
  end


  context '(with new hash config)' do
    let(:config_data) {%Q{---
john-mcfoo:
  :domain:              housetripdev.com.
  :uuid:                0BADCODE-1337-1337-1337-00DEADBEEF00
  :flavor_id:           c1.medium
  :image_id:            ami-27013f53
  :key_name:            john
  :security_group_ids:  
    - sg-6e718319
    - sg-12341234
  :volumes: 
    foo-disk:
      :dev: /dev/sdf
      :uuid: 1234
    }}

    it_should_behave_like 'loaded config'
  end


  context '(with old array config)' do
    let(:config_data) {%Q{---
- :name:                john-mcfoo
  :domain:              housetripdev.com.
  :uuid:                0BADCODE-1337-1337-1337-00DEADBEEF00
  :flavor_id:           c1.medium
  :image_id:            ami-27013f53
  :key_name:            john
  :security_group_ids:  
    - sg-6e718319
    - sg-12341234
  :volumes: 
    - :size: 6
      :name: foo-disk
      :dev: /dev/sdf
      :uuid: 1234
    }}

    it_should_behave_like 'loaded config'
  end
end