require 'rails_helper'

RSpec.describe Dashboard::EarningsCalculator do
  subject(:calculator) { described_class.new(earning_days) }

  let(:earning_days) do
    {
      Date.new(2025, 1, 1) => Dashboard::YearLedger::EarningDay.new(amount: 500, trips: 2),
      Date.new(2025, 2, 1) => Dashboard::YearLedger::EarningDay.new(amount: 500, trips: 1)
    }
  end

  describe '#call' do
    let(:result) { calculator.call }

    it 'calculates total earnings' do
      expect(result[:total]).to eq(1000.0)
    end

    it 'counts distinct working days' do
      expect(result[:days_count]).to eq(2)
    end

    it 'calculates average per day' do
      expect(result[:avg_per_day]).to eq(500.0)
    end

    it 'calculates average per month' do
      expect(result[:avg_per_month]).to eq(500.0)
    end

    it 'exposes the distinct month count' do
      expect(result[:months_count]).to eq(2)
    end

    it 'sums trips_count across all earnings' do
      expect(result[:trips_count]).to eq(3)
    end

    context 'without earnings' do
      let(:earning_days) { {} }

      it 'floors months_count at 1 and zeroes the averages and the total' do
        expect(result[:months_count]).to eq(1)
        expect(result[:avg_per_month]).to eq(0)
        expect(result[:avg_per_day]).to eq(0)
        expect(result[:total]).to eq(0)
      end
    end
  end
end
