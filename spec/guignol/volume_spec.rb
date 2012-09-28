require 'spec_helper'
require 'guignol/models/volume'

describe Guignol::Models::Volume do
  subject { described_class.new(name, options) }

  let(:name) { 'foo' }
  let(:options) {{
    :uuid => 'bar'
  }}

  describe '#initialize' do
    it 'should pass with minimal options' do
      subject
    end
  end
end