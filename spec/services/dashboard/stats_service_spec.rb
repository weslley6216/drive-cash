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

    it 'returns a 12-month profit series for the year' do
      result = described_class.new(year: 2025, month: nil).call

      expect(result[:monthly_profit_series]).to be_an(Array)
      expect(result[:monthly_profit_series].size).to eq(12)
      expect(result[:monthly_profit_series][0]).to eq(400.0)
      expect(result[:monthly_profit_series][1]).to eq(1000.0)
      expect(result[:monthly_profit_series][5]).to eq(0.0)
    end

    it 'returns change_percent as nil when month is not provided' do
      result = described_class.new(year: 2025, month: nil).call

      expect(result[:change_percent]).to be_nil
    end

    it 'returns change_percent vs previous month when month is provided' do
      result = described_class.new(year: 2025, month: 2).call

      expect(result[:change_percent]).to eq(150.0)
    end

    it 'returns nil for change_percent when previous month profit is zero' do
      result = described_class.new(year: 2025, month: 6).call

      expect(result[:change_percent]).to be_nil
    end

    it 'returns a daily profit series for each day of the month when month is provided' do
      result = described_class.new(year: 2025, month: 1).call

      expect(result[:daily_profit_series]).to be_an(Array)
      expect(result[:daily_profit_series].size).to eq(31)
      expect(result[:daily_profit_series][9]).to eq(400.0)
      expect(result[:daily_profit_series][0]).to eq(0.0)
    end

    it 'returns nil for daily_profit_series when no month is provided' do
      result = described_class.new(year: 2025, month: nil).call

      expect(result[:daily_profit_series]).to be_nil
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
