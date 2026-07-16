require 'rails_helper'

RSpec.describe Notifications::Generators::GoalReached do
  let(:user) { create(:user) }
  let(:date) { Date.new(2026, 7, 14) }
  let(:context) { Notifications::Context.new(user: user, date: date) }

  it 'emits a payload when the monthly goal was reached' do
    goal = create(:goal, user: user, kind: 'monthly', metric: 'earnings', target_amount: 1_000,
                         period_start: date.beginning_of_month, period_end: date.end_of_month)
    create(:earning, user: user, date: date, amount: 1_200)

    payloads = described_class.new(context).call

    expect(payloads).to contain_exactly(
      hash_including(
        kind:  'goal_reached',
        data:  hash_including('goal_id' => goal.id, 'month' => goal.period_start.to_s, 'current' => 1_200.0),
        dedup: { 'goal_id' => goal.id }
      )
    )
  end

  it 'emits nothing when the monthly goal is still short of the target' do
    create(:goal, user: user, kind: 'monthly', metric: 'earnings', target_amount: 1_000,
                  period_start: date.beginning_of_month, period_end: date.end_of_month)
    create(:earning, user: user, date: date, amount: 400)

    payloads = described_class.new(context).call

    expect(payloads).to be_empty
  end

  it 'emits nothing when the user has no active monthly goal' do
    payloads = described_class.new(context).call

    expect(payloads).to be_empty
  end
end
