require 'rails_helper'

RSpec.describe Dashboard::DerivedMetrics do
  let(:totals) do
    { earnings: BigDecimal('1000'), expenses: BigDecimal('200'), profit: BigDecimal('800'), days: 10, trips: 40, months_count: 1,
      year: 2025, month: 1 }
  end

  describe '#call' do
    it 'computes the expense percentage of earnings' do
      expect(described_class.new(**totals, earnings: BigDecimal('1000'), expenses: BigDecimal('200')).call[:expenses_percent]).to eq(20.0)
    end

    it 'returns zero expense percentage when there are no earnings' do
      expect(described_class.new(**totals, earnings: BigDecimal('0')).call[:expenses_percent]).to eq(0)
    end

    it 'computes profit per worked day' do
      expect(described_class.new(**totals, profit: BigDecimal('800'), days: 10).call[:profit_per_day]).to eq(80)
    end

    it 'returns zero profit per day when no days were worked' do
      expect(described_class.new(**totals, days: 0).call[:profit_per_day]).to eq(0)
    end

    it 'averages worked days across the counted months' do
      expect(described_class.new(**totals, days: 9, months_count: 2).call[:days_avg_month]).to eq(4.5)
    end

    it 'returns zero day average when no months are counted' do
      expect(described_class.new(**totals, months_count: 0).call[:days_avg_month]).to eq(0)
    end

    it 'averages worked days per week within a month' do
      expect(described_class.new(**totals, days: 9, month: 1, year: 2025).call[:days_avg_week]).to eq(2)
    end

    it 'returns zero weekly average when month is absent (annual view)' do
      expect(described_class.new(**totals, month: nil).call[:days_avg_week]).to eq(0)
    end

    it 'averages trips across the counted months' do
      expect(described_class.new(**totals, trips: 40, months_count: 2).call[:trips_avg_month]).to eq(20)
    end

    it 'averages trips per worked day' do
      expect(described_class.new(**totals, trips: 40, days: 10).call[:trips_avg_day]).to eq(4)
    end

    it 'returns zero trips per day when no days were worked' do
      expect(described_class.new(**totals, days: 0).call[:trips_avg_day]).to eq(0)
    end
  end
end
