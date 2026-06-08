require 'rails_helper'

RSpec.describe Dashboard::StatsService do
  describe '#call' do
    let(:user) { create(:user) }

    before do
      create(:earning, user: user, date: '2025-01-10', amount: 500.00)
      create(:expense, user: user, date: '2025-01-10', amount: 100.00, category: 'fuel', paid: true)
      create(:expense, user: user, date: '2025-01-12', amount: 999.00, category: 'maintenance', paid: false)
      create(:earning, user: user, date: '2025-02-01', amount: 1000.00)
    end

    subject(:result) { described_class.new(year: 2025, month: 1, user: user).call }

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

    it 'returns the monthly profit series for the year (12 entries from earnings minus paid expenses)' do
      expect(result[:monthly_profit_series]).to eq([400.0, 1000.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
    end

    it 'returns the daily profit series for the selected month (one entry per day)' do
      january_series = result[:daily_profit_series]

      expect(january_series.size).to eq(31)
      expect(january_series[9]).to eq(400.0)
      expect(january_series.sum).to eq(400.0)
    end

    it 'returns change_percent as nil when month is not provided' do
      result = described_class.new(year: 2025, month: nil, user: user).call

      expect(result[:change_percent]).to be_nil
    end

    it 'returns change_percent vs previous month when month is provided' do
      result = described_class.new(year: 2025, month: 2, user: user).call

      expect(result[:change_percent]).to eq(150.0)
    end

    it 'returns nil for change_percent when previous month profit is zero' do
      result = described_class.new(year: 2025, month: 6, user: user).call

      expect(result[:change_percent]).to be_nil
    end

    it 'returns nil for daily_profit_series when no month is provided' do
      result = described_class.new(year: 2025, month: nil, user: user).call

      expect(result[:daily_profit_series]).to be_nil
    end

    context 'with multiple working days in the month' do
      before do
        (1..9).each { |day| create(:earning, user: user, date: Date.new(2025, 1, day), amount: 100) }
      end

      it 'calculates average days per week' do
        expect(result[:days_avg_week]).to eq(2)
      end
    end

    it 'counts months once per call across days_avg_month and trips_avg_month' do
      service = described_class.new(year: 2025, user: user)

      allow(Dashboard::ScopeMonthCounter).to receive(:count_for).and_call_original

      service.call

      earnings_scope_calls = Dashboard::ScopeMonthCounter
                             .singleton_class
                             .ancestors
      expect(Dashboard::ScopeMonthCounter).to have_received(:count_for).at_most(:twice)
    end

    context 'with through_month' do
      it 'limits earnings scope to months <= through_month' do
        create(:earning, user: user, date: Date.new(2024, 3, 1), amount: 300)
        create(:earning, user: user, date: Date.new(2024, 7, 1), amount: 999)

        result = described_class.new(year: 2024, through_month: 6, user: user).call

        expect(result[:earnings]).to eq(300.0)
      end

      it 'limits expenses scope to months <= through_month' do
        create(:expense, user: user, date: Date.new(2024, 2, 1), amount: 100, category: 'fuel', paid: true)
        create(:expense, user: user, date: Date.new(2024, 8, 1), amount: 500, category: 'fuel', paid: true)

        result = described_class.new(year: 2024, through_month: 6, user: user).call

        expect(result[:expenses]).to eq(100.0)
      end

      it 'ignores through_month when month is also set (monthly comparison is exact)' do
        create(:earning, user: user, date: Date.new(2024, 6, 1), amount: 400)
        create(:earning, user: user, date: Date.new(2024, 3, 1), amount: 200)

        result = described_class.new(year: 2024, month: 6, through_month: 3, user: user).call

        expect(result[:earnings]).to eq(400.0)
      end
    end
  end
end
