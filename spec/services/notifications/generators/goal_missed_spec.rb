require 'rails_helper'

RSpec.describe Notifications::Generators::GoalMissed do
  let(:user) { create(:user) }
  let(:date) { Date.new(2026, 7, 13) }

  def generate(on: date)
    described_class.new(Notifications::Context.new(user: user, date: on)).call
  end

  def weekly_goal(owner: user)
    create(:goal, user: owner, kind: 'weekly', metric: 'profit', target_amount: 1_100,
                  period_start: Date.new(2026, 7, 6), period_end: Date.new(2026, 7, 12))
  end

  it 'emits the period, metric, target and result of a goal that ended short the day before' do
    goal = weekly_goal
    create(:earning, user: user, date: Date.new(2026, 7, 8), amount: 1_020)
    create(:expense, user: user, date: Date.new(2026, 7, 9), amount: 30, paid: true)

    payloads = generate

    expect(payloads).to contain_exactly(
      kind:  'goal_missed',
      data:  { 'goal_id' => goal.id, 'period_start' => '2026-07-06', 'kind' => 'weekly',
               'metric' => 'profit', 'target' => 1_100.0, 'current' => 990.0 },
      dedup: { 'goal_id' => goal.id, 'period_start' => '2026-07-06' }
    )
  end

  it 'emits a monthly and an annual goal that ended the day before' do
    create(:goal, user: user, kind: 'monthly', metric: 'earnings', target_amount: 5_000,
                  period_start: Date.new(2026, 12, 1), period_end: Date.new(2026, 12, 31))
    create(:goal, user: user, kind: 'annual', metric: 'earnings', target_amount: 50_000,
                  period_start: Date.new(2026, 1, 1), period_end: Date.new(2026, 12, 31))
    create(:earning, user: user, date: Date.new(2026, 12, 10), amount: 1_000)

    payloads = generate(on: Date.new(2027, 1, 1))

    expect(payloads.map { |payload| payload[:data]['kind'] }).to contain_exactly('monthly', 'annual')
  end

  it 'skips a goal that was reached' do
    weekly_goal
    create(:earning, user: user, date: Date.new(2026, 7, 8), amount: 1_200)

    payloads = generate

    expect(payloads).to be_empty
  end

  it 'emits nothing on the last day of the period' do
    weekly_goal
    create(:earning, user: user, date: Date.new(2026, 7, 8), amount: 500)

    payloads = generate(on: Date.new(2026, 7, 12))

    expect(payloads).to be_empty
  end

  it 'emits nothing two days after the period ended' do
    weekly_goal
    create(:earning, user: user, date: Date.new(2026, 7, 8), amount: 500)

    payloads = generate(on: Date.new(2026, 7, 14))

    expect(payloads).to be_empty
  end

  it 'emits nothing for a period with no earning and no paid expense' do
    weekly_goal
    create(:expense, user: user, date: Date.new(2026, 7, 8), amount: 50, paid: false)

    payloads = generate

    expect(payloads).to be_empty
  end

  it 'emits a period with only a paid expense' do
    weekly_goal
    create(:expense, user: user, date: Date.new(2026, 7, 8), amount: 50, paid: true)

    payloads = generate

    expect(payloads.first[:data]).to include('current' => -50.0)
  end

  it 'leaves the goals of another user out' do
    other_user = create(:user)
    weekly_goal(owner: other_user)
    create(:earning, user: other_user, date: Date.new(2026, 7, 8), amount: 500)

    payloads = generate

    expect(payloads).to be_empty
  end
end
