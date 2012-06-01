require 'spec_helper'
require 'guignol/models/volume'

describe Guignol::Models::Volume do
  subject { described_class.new(options) }

  let(:options) {{
    :name => 'foo',
    :uuid => 'bar'
  }}

  describe '#initialize' do
    it 'should pass with minimal options' do
      subject
    end
  end
end