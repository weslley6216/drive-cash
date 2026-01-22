# spec/components/concerns/formatting_spec.rb
require 'rails_helper'

RSpec.describe Formatting do
  let(:helper) { Class.new { include Formatting }.new }

  describe '#format_currency' do
    it 'formats BRL correctly' do
      result = helper.format_currency(1234.50).squish

      expect(result).to eq('R$ 1.234,50')
    end
  end

  describe '#format_percentage' do
    it 'formats percentage with precision' do
      expect(helper.format_percentage(33.3333)).to eq('33,3')
    end
  end
end
