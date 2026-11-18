require 'rails_helper'

RSpec.describe Goals::Outcomes::Missed do
  let(:user) { create(:user) }
  let(:target) { 1_100 }
  let(:date) { Date.new(2026, 7, 13) }
  let(:goal) do
    create(:goal, user: user, kind: 'weekly', metric: 'profit', target_amount: target,
                  period_start: Date.new(2026, 7, 6), period_end: Date.new(2026, 7, 12))
  end
  let(:totals) { Goals::DailyTotals.for(user: user, range: goal.period_start..goal.period_end) }
  let(:outcome) { described_class.new(goal: goal, totals: totals, date: date).call }

  before do
    create(:earning, user: user, date: Date.new(2026, 7, 6), amount: 250)
    create(:earning, user: user, date: Date.new(2026, 7, 8), amount: 300)
    create(:expense, user: user, date: Date.new(2026, 7, 8), amount: 32, paid: true)
    create(:earning, user: user, date: Date.new(2026, 7, 10), amount: 270)
    create(:earning, user: user, date: Date.new(2026, 7, 11), amount: 202)
    create(:earning, date: Date.new(2026, 7, 8), amount: 9_000)
  end

  it 'measures how far the result fell short of the target' do
    expect(outcome).to have_attributes(state: 'missed', target: 1_100, achieved: 990, percent: 90,
                                       shortfall: 110, near: true)
  end

  context 'with a result under eighty percent' do
    let(:target) { 1_300 }

    it 'calls the result closed' do
      expect(outcome).to have_attributes(percent: 76, near: false)
    end
  end

  it 'keeps the pace of the worked days and the best day by the goal metric' do
    expect(outcome).to have_attributes(worked_days: 4, per_day: BigDecimal('247.5'))
    expect(outcome.best_day).to have_attributes(date: Date.new(2026, 7, 10), value: 270)
  end

  it 'adjusts the next target to the recent average rounded down to the ten' do
    create(:earning, user: user, date: Date.new(2026, 6, 23), amount: 1_100)
    create(:earning, user: user, date: Date.new(2026, 6, 30), amount: 1_060)

    expect(outcome.adjusted_target).to eq(1_050)
  end

  it 'offers no adjustment when the recent average reaches the target' do
    create(:earning, user: user, date: Date.new(2026, 6, 30), amount: 1_500)

    expect(outcome.adjusted_target).to be_nil
  end

  it 'plans the next period on the average worked days with the target per day' do
    [29, 30].each { |day| create(:earning, user: user, date: Date.new(2026, 6, day), amount: 100) }
    create(:earning, user: user, date: Date.new(2026, 7, 1), amount: 100)

    expect(outcome).to have_attributes(work_days: 4, per_work_day: 275)
  end

  it 'carries the track record of the previous goals' do
    create(:goal, user: user, kind: 'weekly', metric: 'profit', target_amount: 500,
                  period_start: Date.new(2026, 6, 22), period_end: Date.new(2026, 6, 28))
    create(:goal, user: user, kind: 'weekly', metric: 'profit', target_amount: 500,
                  period_start: Date.new(2026, 6, 29), period_end: Date.new(2026, 7, 5))
    create(:earning, user: user, date: Date.new(2026, 6, 23), amount: 600)

    expect(outcome.track_record).to have_attributes(hits: 1, total: 2)
  end

  it 'offers the period after the goal with no goal there yet' do
    expect(outcome).to have_attributes(next_period: Date.new(2026, 7, 13)..Date.new(2026, 7, 19), next_goal: nil)
  end

  it 'keeps the pace at zero for a period without a worked day' do
    empty_week = create(:goal, user: user, kind: 'weekly', metric: 'profit', target_amount: 1_100,
                               period_start: Date.new(2026, 6, 1), period_end: Date.new(2026, 6, 7))
    empty_totals = Goals::DailyTotals.for(user: user, range: empty_week.period_start..empty_week.period_end)

    result = described_class.new(goal: empty_week, totals: empty_totals, date: date).call

    expect(result).to have_attributes(worked_days: 0, per_day: 0, percent: 0, next_period: nil)
  end
end
