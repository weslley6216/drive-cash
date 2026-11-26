require 'rails_helper'

RSpec.describe Formatting do
  let(:helper) { Class.new { include Formatting }.new }

  describe '#format_currency' do
    it 'joins the symbol and the value with a non-breaking space' do
      expect(helper.format_currency(1234.50)).to eq("R$\u00A01.234,50")
    end

    it 'puts the minus sign before the symbol for a negative value' do
      expect(helper.format_currency(-80)).to eq("-R$\u00A080,00")
    end
  end

  describe '#format_currency_short' do
    it 'rounds to whole reais with a non-breaking space after the symbol' do
      expect(helper.format_currency_short(1234.4)).to eq("R$\u00A01.234")
    end
  end

  describe '#format_percentage' do
    it 'formats percentage with precision' do
      expect(helper.format_percentage(33.3333)).to eq('33,3')
    end
  end

  describe '#month_abbr' do
    it 'returns the capitalized month abbreviation' do
      expect(helper.month_abbr(5)).to eq('Mai')
    end
  end

  describe '#short_month' do
    it 'returns the lowercase month abbreviation' do
      expect(helper.short_month(5)).to eq('mai')
    end
  end
end
