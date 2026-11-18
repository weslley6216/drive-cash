require 'rails_helper'

RSpec.describe Goals::RecentPeriods do
  let(:user) { create(:user) }
  let(:metric) { 'earnings' }
  let(:goal) do
    create(:goal, user: user, kind: 'weekly', metric: metric, target_amount: 1_100,
                  period_start: Date.new(2026, 7, 6), period_end: Date.new(2026, 7, 12))
  end

  def recent_for(target_goal)
    totals = Goals::DailyTotals.for(user: target_goal.user, range: described_class.span(target_goal))
    described_class.new(goal: target_goal, totals: totals)
  end

  def earn(date, amount, owner: user)
    create(:earning, user: owner, date: date, amount: amount)
  end

  it 'averages the result of the goal period and the three periods before it' do
    earn(Date.new(2026, 6, 16), 1_000)
    earn(Date.new(2026, 6, 23), 1_100)
    earn(Date.new(2026, 6, 30), 1_200)
    earn(Date.new(2026, 7, 7), 900)
    earn(Date.new(2026, 6, 9), 5_000)

    average = recent_for(goal).average_result

    expect(average).to eq(1_050)
  end

  it 'leaves the periods with no entry out of the average' do
    earn(Date.new(2026, 6, 23), 1_100)
    earn(Date.new(2026, 7, 7), 900)

    average = recent_for(goal).average_result

    expect(average).to eq(1_000)
  end

  context 'with a profit goal' do
    let(:metric) { 'profit' }

    it 'counts a period with only a paid expense as active' do
      earn(Date.new(2026, 7, 7), 1_000)
      create(:expense, user: user, date: Date.new(2026, 6, 23), amount: 200, paid: true)

      average = recent_for(goal).average_result

      expect(average).to eq(400)
    end
  end

  it 'walks back by calendar month for a monthly goal' do
    july = create(:goal, user: user, kind: 'monthly', metric: 'earnings', target_amount: 1_000,
                         period_start: Date.new(2026, 7, 1), period_end: Date.new(2026, 7, 31))
    earn(Date.new(2026, 4, 10), 400)
    earn(Date.new(2026, 7, 10), 800)
    earn(Date.new(2026, 3, 10), 9_000)

    average = recent_for(july).average_result

    expect(average).to eq(600)
  end

  it 'averages the worked days of the active periods' do
    [23, 24, 25].each { |day| earn(Date.new(2026, 6, day), 100) }
    [7, 8, 9, 10].each { |day| earn(Date.new(2026, 7, day), 100) }

    worked_days = recent_for(goal).average_worked_days

    expect(worked_days).to eq(3.5)
  end

  it 'has no average without any entry in the four periods' do
    recent = recent_for(goal)

    expect(recent).to have_attributes(average_result: nil, average_worked_days: nil)
  end

  it 'ignores the entries of another user' do
    earn(Date.new(2026, 7, 7), 900, owner: create(:user))

    average = recent_for(goal).average_result

    expect(average).to be_nil
  end
end
