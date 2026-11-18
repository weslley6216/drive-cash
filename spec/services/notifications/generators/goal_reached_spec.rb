require 'rails_helper'

RSpec.describe Notifications::Generators::GoalReached do
  let(:user) { create(:user) }
  let(:date) { Date.new(2026, 7, 14) }
  let(:context) { Notifications::Context.new(user: user, date: date) }

  it 'emits the period, metric and target of a reached monthly earnings goal' do
    goal = create(:goal, user: user, kind: 'monthly', metric: 'earnings', target_amount: 1_000,
                         period_start: Date.new(2026, 7, 1), period_end: Date.new(2026, 7, 31))
    create(:earning, user: user, date: date, amount: 1_200)

    payloads = described_class.new(context).call

    expect(payloads).to contain_exactly(
      kind:  'goal_reached',
      data:  { 'goal_id' => goal.id, 'period_start' => '2026-07-01', 'kind' => 'monthly',
               'metric' => 'earnings', 'target' => 1_000.0, 'current' => 1_200.0 },
      dedup: { 'goal_id' => goal.id }
    )
  end

  it 'emits a reached weekly profit goal with paid expenses taken out' do
    create(:goal, user: user, kind: 'weekly', metric: 'profit', target_amount: 500,
                  period_start: Date.new(2026, 7, 13), period_end: Date.new(2026, 7, 19))
    create(:earning, user: user, date: date, amount: 900)
    create(:expense, user: user, date: date, amount: 300, paid: true)

    payloads = described_class.new(context).call

    expect(payloads.first[:data]).to include('kind' => 'weekly', 'metric' => 'profit',
                                             'period_start' => '2026-07-13', 'current' => 600.0)
  end

  it 'emits a reached annual goal' do
    create(:goal, user: user, kind: 'annual', metric: 'earnings', target_amount: 1_000,
                  period_start: Date.new(2026, 1, 1), period_end: Date.new(2026, 12, 31))
    create(:earning, user: user, date: Date.new(2026, 3, 10), amount: 1_200)

    payloads = described_class.new(context).call

    expect(payloads.first[:data]).to include('kind' => 'annual', 'period_start' => '2026-01-01', 'target' => 1_000.0)
  end

  it 'emits one payload per reached goal and skips the ones short of the target' do
    create(:goal, user: user, kind: 'monthly', metric: 'earnings', target_amount: 1_000,
                  period_start: Date.new(2026, 7, 1), period_end: Date.new(2026, 7, 31))
    create(:goal, user: user, kind: 'weekly', metric: 'earnings', target_amount: 5_000,
                  period_start: Date.new(2026, 7, 13), period_end: Date.new(2026, 7, 19))
    create(:earning, user: user, date: date, amount: 1_200)

    payloads = described_class.new(context).call

    expect(payloads.map { |payload| payload[:data]['kind'] }).to eq(['monthly'])
  end

  it 'emits nothing for a reached goal that is no longer active on the date' do
    create(:goal, user: user, kind: 'monthly', metric: 'earnings', target_amount: 1_000,
                  period_start: Date.new(2026, 6, 1), period_end: Date.new(2026, 6, 30))
    create(:earning, user: user, date: Date.new(2026, 6, 10), amount: 1_200)

    payloads = described_class.new(context).call

    expect(payloads).to be_empty
  end

  it 'emits nothing when the user has no goal' do
    payloads = described_class.new(context).call

    expect(payloads).to be_empty
  end
end
