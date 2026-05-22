require 'rails_helper'

RSpec.describe Dashboard::StatsService do
  describe '#call' do
    before do
      create(:earning, date: '2025-01-10', amount: 500.00)
      create(:expense, date: '2025-01-10', amount: 100.00, category: 'fuel', paid: true)
      create(:expense, date: '2025-01-12', amount: 999.00, category: 'maintenance', paid: false)
      create(:earning, date: '2025-02-01', amount: 1000.00)
    end

    subject(:result) { described_class.new(year: 2025, month: 1).call }

    it 'calculates total earnings for the period' do
      expect(result[:earnings]).to eq(500.00)
    end

    it 'calculates total expenses for the period' do
      expect(result[:expenses]).to eq(100.00)
    end

    it 'calculates profit' do
      expect(result[:profit]).to eq(400.00)
    end

    it 'calculates profit per day' do
      expect(result[:profit_per_day]).to eq(400.00)
    end

    it 'calculates expenses percentage' do
      expect(result[:expenses_percent]).to eq(20.0)
    end

    context 'with multiple working days in the month' do
      before do
        (1..9).each { |day| create(:earning, date: Date.new(2025, 1, day), amount: 100) }
      end

      it 'calculates average days per week' do
        expect(result[:days_avg_week]).to eq(2)
      end
    end
  end

  describe '.available_years' do
    it 'delegates to Dashboard::AvailableYears.fetch' do
      create(:earning, date: '2021-01-01')

      result = described_class.available_years

      expect(result).to include(2021)
    end
  end
end
