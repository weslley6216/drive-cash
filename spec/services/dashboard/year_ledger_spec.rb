require 'rails_helper'

RSpec.describe Dashboard::YearLedger do
  let(:user) { create(:user) }
  let(:ledger) { described_class.new(user: user, year: 2026) }

  describe '#earning_days and #earned_in' do
    it 'groups the earnings of the year by day with amount and trips' do
      create(:earning, user: user, date: Date.new(2026, 3, 5), amount: 100, trips_count: 2)
      create(:earning, user: user, date: Date.new(2026, 3, 5), amount: 50, trips_count: 1)
      create(:earning, user: user, date: Date.new(2026, 4, 1), amount: 30, trips_count: 1)

      expect(ledger.earning_days[Date.new(2026, 3, 5)]).to eq(Dashboard::YearLedger::EarningDay.new(amount: 150, trips: 3))
      expect(ledger.earning_days(3).keys).to eq([Date.new(2026, 3, 5)])
      expect(ledger.earned_in(3)).to eq(150)
      expect(ledger.earned_in).to eq(180)
    end
  end

  describe '#spent_in, #spent_on and #spent_by_category' do
    it 'ignores unpaid expenses and other years' do
      create(:expense, user: user, date: Date.new(2026, 3, 6), amount: 40, category: 'fuel', paid: true)
      create(:expense, user: user, date: Date.new(2026, 3, 6), amount: 999, category: 'fuel', paid: false)
      create(:expense, user: user, date: Date.new(2025, 3, 6), amount: 77, category: 'fuel', paid: true)

      expect(ledger.spent_in(3)).to eq(40)
      expect(ledger.spent_on(Date.new(2026, 3, 6))).to eq(40)
      expect(ledger.spent_by_category(3)).to eq({ 'fuel' => 40 })
    end

    it 'sums expenses by category for the month or the whole year' do
      create(:expense, user: user, date: Date.new(2026, 3, 1), amount: 40, category: 'fuel', paid: true)
      create(:expense, user: user, date: Date.new(2026, 4, 1), amount: 10, category: 'fuel', paid: true)
      create(:expense, user: user, date: Date.new(2026, 4, 2), amount: 5, category: 'meals', paid: true)

      expect(ledger.spent_by_category(4)).to eq({ 'fuel' => 10, 'meals' => 5 })
      expect(ledger.spent_by_category).to eq({ 'fuel' => 50, 'meals' => 5 })
    end
  end

  describe 'days and months without records' do
    it 'answers zero for days and months without records' do
      expect(ledger.earned_on(Date.new(2026, 2, 1))).to eq(0)
      expect(ledger.spent_in(2)).to eq(0)
      expect(ledger.earning_days(2)).to eq({})
    end
  end

  describe '#daily_totals' do
    it 'builds daily totals covering the whole year' do
      create(:earning, user: user, date: Date.new(2026, 3, 5), amount: 100)
      create(:expense, user: user, date: Date.new(2026, 3, 5), amount: 40, paid: true)
      goal = build(:goal, metric: 'profit', period_start: Date.new(2026, 3, 1), period_end: Date.new(2026, 3, 31))

      expect(ledger.daily_totals.metric_for(goal)).to eq(60)
      expect(ledger.daily_totals.covers?(Date.new(2026, 1, 1)..Date.new(2026, 12, 31))).to be(true)
    end
  end

  describe 'query count' do
    it 'loads each side in a single query' do
      ledger

      queries = count_queries do
        ledger.earned_in
        ledger.spent_in
        ledger.spent_by_category
        ledger.daily_totals
      end

      expect(queries).to eq(2)
    end

    it 'loads only the expenses side when only expenses are asked' do
      ledger

      queries = count_queries { ledger.spent_by_category }

      expect(queries).to eq(1)
    end
  end
end
