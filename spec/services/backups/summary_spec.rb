require 'rails_helper'

RSpec.describe Backups::Summary do
  def entry(date, amount)
    Backups::Snapshot::Entry.new(date: date, amount: amount)
  end

  describe '#call' do
    it 'aggregates one row per month with earnings, paid expenses and profit' do
      earnings = [entry(Date.new(2026, 1, 5), 1_000.0), entry(Date.new(2026, 1, 20), 500.0)]
      expenses = [entry(Date.new(2026, 1, 10), 300.0)]

      result = described_class.new(earnings: earnings, expenses: expenses, savings_percentage: 35).call

      expect(result.rows.first[0]).to eq('2026-01')
      expect(result.rows.first[1]).to eq(1_500.0)
      expect(result.rows.first[2]).to eq(300.0)
      expect(result.rows.first[3]).to eq(1_200.0)
    end

    it 'estimates the savings column as a percentage of the profit' do
      result = described_class.new(earnings: [entry(Date.new(2026, 1, 5), 1_000.0)], expenses: [], savings_percentage: 35).call

      expect(result.rows.first[4]).to eq(350.0)
    end

    it 'floors the savings estimate at zero on a negative month' do
      result = described_class.new(earnings: [], expenses: [entry(Date.new(2026, 1, 5), 400.0)], savings_percentage: 35).call

      expect(result.rows.first[3]).to eq(-400.0)
      expect(result.rows.first[4]).to eq(0.0)
    end

    it 'orders months chronologically across years' do
      earnings = [entry(Date.new(2026, 2, 1), 10.0), entry(Date.new(2025, 12, 1), 10.0), entry(Date.new(2026, 1, 1), 10.0)]

      result = described_class.new(earnings: earnings, expenses: [], savings_percentage: 35).call

      expect(result.rows.first(3).map(&:first)).to eq(['2025-12', '2026-01', '2026-02'])
    end

    it 'includes months that only have expenses' do
      result = described_class.new(earnings: [], expenses: [entry(Date.new(2026, 3, 4), 90.0)], savings_percentage: 35).call

      expect(result.rows.first[0]).to eq('2026-03')
      expect(result.rows.first[1]).to eq(0.0)
    end

    it 'appends one annual total row per year after every month row' do
      earnings = [entry(Date.new(2025, 12, 1), 100.0), entry(Date.new(2026, 1, 1), 200.0)]

      result = described_class.new(earnings: earnings, expenses: [], savings_percentage: 50).call

      expect(result.rows.map(&:first)).to eq(['2025-12', '2026-01', 'Total 2025', 'Total 2026'])
      expect(result.rows[2]).to eq(['Total 2025', 100.0, 0.0, 100.0, 50.0])
      expect(result.rows[3]).to eq(['Total 2026', 200.0, 0.0, 200.0, 100.0])
    end

    it 'sums the already floored monthly savings into the annual total' do
      earnings = [entry(Date.new(2026, 1, 1), 1_000.0)]
      expenses = [entry(Date.new(2026, 2, 1), 400.0)]

      result = described_class.new(earnings: earnings, expenses: expenses, savings_percentage: 50).call

      expect(result.rows.last).to eq(['Total 2026', 1_000.0, 400.0, 600.0, 500.0])
    end

    it 'reports how many rows are months so the chart can skip the totals' do
      earnings = [entry(Date.new(2025, 12, 1), 10.0), entry(Date.new(2026, 1, 1), 10.0)]

      result = described_class.new(earnings: earnings, expenses: [], savings_percentage: 35).call

      expect(result.month_count).to eq(2)
    end

    it 'returns no rows when the user has no records at all' do
      result = described_class.new(earnings: [], expenses: [], savings_percentage: 35).call

      expect(result.rows).to eq([])
      expect(result.month_count).to eq(0)
    end

    it 'rounds float artifacts out of the money columns' do
      earnings = [entry(Date.new(2026, 1, 1), 0.1), entry(Date.new(2026, 1, 2), 0.2)]

      result = described_class.new(earnings: earnings, expenses: [], savings_percentage: 35).call

      expect(result.rows.first[1]).to eq(0.3)
    end
  end
end
