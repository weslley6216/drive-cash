require 'rails_helper'

RSpec.describe Goals::DailyTotals do
  let(:user) { create(:user) }

  describe '.for' do
    it 'sums earned amounts per goal period for an earnings goal' do
      goal = build(:goal, metric: 'earnings', period_start: Date.new(2026, 6, 1), period_end: Date.new(2026, 6, 30))
      create(:earning, user: user, date: Date.new(2026, 6, 5), amount: 200)
      create(:earning, user: user, date: Date.new(2026, 6, 10), amount: 300)

      totals = described_class.for(user: user, range: goal.period_start..goal.period_end)

      expect(totals.metric_for(goal)).to eq(500)
    end

    it 'subtracts paid expenses for a profit goal' do
      goal = build(:goal, metric: 'profit', period_start: Date.new(2026, 6, 1), period_end: Date.new(2026, 6, 30))
      create(:earning, user: user, date: Date.new(2026, 6, 5), amount: 500)
      create(:expense, user: user, date: Date.new(2026, 6, 6), amount: 200, paid: true)

      totals = described_class.for(user: user, range: goal.period_start..goal.period_end)

      expect(totals.metric_for(goal)).to eq(300)
    end

    it 'ignores unpaid expenses for a profit goal' do
      goal = build(:goal, metric: 'profit', period_start: Date.new(2026, 6, 1), period_end: Date.new(2026, 6, 30))
      create(:earning, user: user, date: Date.new(2026, 6, 5), amount: 500)
      create(:expense, user: user, date: Date.new(2026, 6, 6), amount: 200, paid: false)

      totals = described_class.for(user: user, range: goal.period_start..goal.period_end)

      expect(totals.metric_for(goal)).to eq(500)
    end

    it 'defaults days without activity to zero' do
      goal = build(:goal, metric: 'profit', period_start: Date.new(2026, 6, 1), period_end: Date.new(2026, 6, 30))

      totals = described_class.for(user: user, range: goal.period_start..goal.period_end)

      expect(totals.metric_for(goal)).to eq(0)
    end
  end

  describe '.for_goals' do
    it 'derives the range covering the earliest and latest goal periods, keeping each goal isolated' do
      older_goal = build(:goal, metric: 'earnings', period_start: Date.new(2026, 4, 1), period_end: Date.new(2026, 4, 30))
      newer_goal = build(:goal, metric: 'earnings', period_start: Date.new(2026, 6, 1), period_end: Date.new(2026, 6, 30))
      create(:earning, user: user, date: Date.new(2026, 4, 15), amount: 100)
      create(:earning, user: user, date: Date.new(2026, 6, 15), amount: 400)

      totals = described_class.for_goals(user: user, goals: [older_goal, newer_goal])

      expect(totals.metric_for(older_goal)).to eq(100)
      expect(totals.metric_for(newer_goal)).to eq(400)
    end

    it 'returns empty totals without querying when there are no goals' do
      goal = build(:goal, metric: 'earnings', period_start: Date.new(2026, 6, 1), period_end: Date.new(2026, 6, 30))
      create(:earning, user: user, date: Date.new(2026, 6, 5), amount: 200)

      totals = described_class.for_goals(user: user, goals: [])

      expect(totals.metric_for(goal)).to eq(0)
    end
  end

  describe '#metric_on' do
    it 'returns the metric value for a single day' do
      goal = build(:goal, metric: 'profit', period_start: Date.new(2026, 6, 1), period_end: Date.new(2026, 6, 30))
      create(:earning, user: user, date: Date.new(2026, 6, 5), amount: 500)
      create(:expense, user: user, date: Date.new(2026, 6, 5), amount: 100, paid: true)
      create(:earning, user: user, date: Date.new(2026, 6, 6), amount: 50)

      totals = described_class.for(user: user, range: goal.period_start..goal.period_end)

      expect(totals.metric_on(goal, Date.new(2026, 6, 5))).to eq(400)
      expect(totals.metric_on(goal, Date.new(2026, 6, 6))).to eq(50)
      expect(totals.metric_on(goal, Date.new(2026, 6, 7))).to eq(0)
    end
  end
end
