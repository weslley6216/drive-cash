require 'rails_helper'

RSpec.describe Dashboard::MetricsCalculator do
  describe '#per_trip' do
    it 'returns profit divided by trips rounded to 2 decimals' do
      calculator = described_class.new(profit: 200, trips: 5, earnings: 0)

      expect(calculator.per_trip).to eq(40.0)
    end

    it 'returns 0 when trips is zero' do
      calculator = described_class.new(profit: 200, trips: 0, earnings: 0)

      expect(calculator.per_trip).to eq(0)
    end
  end

  describe '#per_km' do
    it 'returns profit divided by km rounded to 2 decimals' do
      calculator = described_class.new(profit: 500, trips: 0, earnings: 0)

      expect(calculator.per_km(1000)).to eq(0.5)
    end

    it 'returns nil when km is nil' do
      calculator = described_class.new(profit: 500, trips: 0, earnings: 0)

      expect(calculator.per_km(nil)).to be_nil
    end

    it 'returns nil when km is zero' do
      calculator = described_class.new(profit: 500, trips: 0, earnings: 0)

      expect(calculator.per_km(0)).to be_nil
    end
  end

  describe '#margin' do
    it 'returns (profit / earnings) * 100 rounded to 1 decimal' do
      calculator = described_class.new(profit: 400, trips: 0, earnings: 500)

      expect(calculator.margin).to eq(80.0)
    end

    it 'returns 0 when earnings is zero' do
      calculator = described_class.new(profit: 100, trips: 0, earnings: 0)

      expect(calculator.margin).to eq(0)
    end
  end

  describe '.from_stats' do
    it 'builds a calculator from a stats hash' do
      stats = { profit: 200, trips: 5, earnings: 250 }
      calculator = described_class.from_stats(stats)

      expect(calculator.per_trip).to eq(40.0)
      expect(calculator.per_km(100)).to eq(2.0)
      expect(calculator.margin).to eq(80.0)
    end
  end
end
