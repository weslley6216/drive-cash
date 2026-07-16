require 'rails_helper'

RSpec.describe Plans::Comparison do
  subject(:comparison) { described_class.new }

  describe '#yearly_discount_percent' do
    it 'derives the yearly discount from the catalog prices' do
      expect(comparison.yearly_discount_percent).to eq(20)
    end
  end

  describe '#pro_monthly_equivalent' do
    it 'splits the yearly price across the twelve months' do
      expect(comparison.pro_monthly_equivalent.round(2)).to eq(BigDecimal('11.92'))
    end
  end

  describe '#pro_price_month' do
    it 'exposes the monthly price' do
      expect(comparison.pro_price_month).to eq(BigDecimal('14.90'))
    end
  end

  describe '#pro_price_year' do
    it 'exposes the yearly price' do
      expect(comparison.pro_price_year).to eq(BigDecimal('143.00'))
    end
  end

  describe '#free_price_month' do
    it 'costs nothing' do
      expect(comparison.free_price_month).to eq(0)
    end
  end

  describe '#pro_features' do
    it 'lists the pro benefits' do
      expect(comparison.pro_features).to eq(%i[exports insights goals history caju backup])
    end
  end

  describe '#free_features' do
    it 'lists the free benefits' do
      expect(comparison.free_features).to eq(%i[records caju_limit single_goal history_limit])
    end
  end
end
