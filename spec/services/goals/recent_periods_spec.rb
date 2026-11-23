require 'rails_helper'

RSpec.describe Goals::RecentPeriods do
  let(:user) { create(:user) }
  let(:metric) { 'earnings' }
  let(:goal) do
    create(:goal, user: user, kind: 'weekly', metric: metric, target_amount: 1_100,
                  period_start: Date.new(2026, 7, 6), period_end: Date.new(2026, 7, 12))
  end

  it 'averages the result of the goal period and the three periods before it' do
    create(:earning, user: user, date: Date.new(2026, 6, 16), amount: 1_000)
    create(:earning, user: user, date: Date.new(2026, 6, 23), amount: 1_100)
    create(:earning, user: user, date: Date.new(2026, 6, 30), amount: 1_200)
    create(:earning, user: user, date: Date.new(2026, 7, 7), amount: 900)
    create(:earning, user: user, date: Date.new(2026, 6, 9), amount: 5_000)

    average = described_class.new(goal:   goal,
                                  totals: Goals::DailyTotals.for(user: goal.user, range: described_class.span(goal))).average_result

    expect(average).to eq(1_050)
  end

  it 'leaves the periods with no entry out of the average' do
    create(:earning, user: user, date: Date.new(2026, 6, 23), amount: 1_100)
    create(:earning, user: user, date: Date.new(2026, 7, 7), amount: 900)

    average = described_class.new(goal:   goal,
                                  totals: Goals::DailyTotals.for(user: goal.user, range: described_class.span(goal))).average_result

    expect(average).to eq(1_000)
  end

  context 'with a profit goal' do
    let(:metric) { 'profit' }

    it 'counts a period with only a paid expense as active' do
      create(:earning, user: user, date: Date.new(2026, 7, 7), amount: 1_000)
      create(:expense, user: user, date: Date.new(2026, 6, 23), amount: 200, paid: true)

      average = described_class.new(goal:   goal,
                                    totals: Goals::DailyTotals.for(user: goal.user, range: described_class.span(goal))).average_result

      expect(average).to eq(400)
    end
  end

  it 'walks back by calendar month for a monthly goal' do
    july = create(:goal, user: user, kind: 'monthly', metric: 'earnings', target_amount: 1_000,
                         period_start: Date.new(2026, 7, 1), period_end: Date.new(2026, 7, 31))
    create(:earning, user: user, date: Date.new(2026, 4, 10), amount: 400)
    create(:earning, user: user, date: Date.new(2026, 7, 10), amount: 800)
    create(:earning, user: user, date: Date.new(2026, 3, 10), amount: 9_000)

    average = described_class.new(goal:   july,
                                  totals: Goals::DailyTotals.for(user: july.user, range: described_class.span(july))).average_result

    expect(average).to eq(600)
  end

  it 'averages the worked days of the active periods' do
    [23, 24, 25].each { |day| create(:earning, user: user, date: Date.new(2026, 6, day), amount: 100) }
    [7, 8, 9, 10].each { |day| create(:earning, user: user, date: Date.new(2026, 7, day), amount: 100) }

    worked_days = described_class.new(goal:   goal,
                                      totals: Goals::DailyTotals.for(user: goal.user, range: described_class.span(goal))).average_worked_days

    expect(worked_days).to eq(3.5)
  end

  it 'has no average without any entry in the four periods' do
    recent = described_class.new(goal: goal, totals: Goals::DailyTotals.for(user: goal.user, range: described_class.span(goal)))

    expect(recent).to have_attributes(average_result: nil, average_worked_days: nil)
  end

  it 'ignores the entries of another user' do
    create(:earning, user: create(:user), date: Date.new(2026, 7, 7), amount: 900)

    average = described_class.new(goal:   goal,
                                  totals: Goals::DailyTotals.for(user: goal.user, range: described_class.span(goal))).average_result

    expect(average).to be_nil
  end
end
