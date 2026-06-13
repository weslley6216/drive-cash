require 'rails_helper'

RSpec.describe Dashboard::DerivedMetrics do
  def build(**overrides)
    defaults = { earnings: 1000, expenses: 200, profit: 800, days: 10, trips: 40, months_count: 1, year: 2025, month: 1 }
    attrs = defaults.merge(overrides)
    %i[earnings expenses profit].each { |key| attrs[key] = BigDecimal(attrs[key].to_s) }
    described_class.new(**attrs).call
  end

  describe '#call' do
    it 'computes the expense percentage of earnings' do
      expect(build(earnings: 1000, expenses: 200)[:expenses_percent]).to eq(20.0)
    end

    it 'returns zero expense percentage when there are no earnings' do
      expect(build(earnings: 0)[:expenses_percent]).to eq(0)
    end

    it 'computes profit per worked day' do
      expect(build(profit: 800, days: 10)[:profit_per_day]).to eq(80)
    end

    it 'returns zero profit per day when no days were worked' do
      expect(build(days: 0)[:profit_per_day]).to eq(0)
    end

    it 'averages worked days across the counted months' do
      expect(build(days: 9, months_count: 2)[:days_avg_month]).to eq(4.5)
    end

    it 'returns zero day average when no months are counted' do
      expect(build(months_count: 0)[:days_avg_month]).to eq(0)
    end

    it 'averages worked days per week within a month' do
      expect(build(days: 9, month: 1, year: 2025)[:days_avg_week]).to eq(2)
    end

    it 'returns zero weekly average when month is absent (annual view)' do
      expect(build(month: nil)[:days_avg_week]).to eq(0)
    end

    it 'averages trips across the counted months' do
      expect(build(trips: 40, months_count: 2)[:trips_avg_month]).to eq(20)
    end

    it 'averages trips per worked day' do
      expect(build(trips: 40, days: 10)[:trips_avg_day]).to eq(4)
    end

    it 'returns zero trips per day when no days were worked' do
      expect(build(days: 0)[:trips_avg_day]).to eq(0)
    end
  end
end
