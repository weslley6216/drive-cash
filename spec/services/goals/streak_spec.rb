require 'rails_helper'

RSpec.describe Goals::Streak do
  let(:user) { create(:user) }

  it 'counts the goal itself and every adjacent previous goal that was hit' do
    create(:goal, user: user, kind: 'monthly', metric: 'earnings', target_amount: 1_000, period_start: Date.new(2026, 4, 1),
           period_end: Date.new(2026, 4, 30))
    create(:goal, user: user, kind: 'monthly', metric: 'earnings', target_amount: 1_000, period_start: Date.new(2026, 5, 1),
           period_end: Date.new(2026, 5, 31))
    june = create(:goal, user: user, kind: 'monthly', metric: 'earnings', target_amount: 1_000, period_start: Date.new(2026, 6, 1),
                  period_end: Date.new(2026, 6, 30))
    [4, 5, 6].each { |month| create(:earning, user: user, date: Date.new(2026, month, 10), amount: 1_200) }

    count = described_class.new(goal: june).count

    expect(count).to eq(3)
  end

  it 'stops at a previous goal that was missed' do
    create(:goal, user: user, kind: 'monthly', metric: 'earnings', target_amount: 1_000, period_start: Date.new(2026, 4, 1),
           period_end: Date.new(2026, 4, 30))
    create(:goal, user: user, kind: 'monthly', metric: 'earnings', target_amount: 1_000, period_start: Date.new(2026, 5, 1),
           period_end: Date.new(2026, 5, 31))
    june = create(:goal, user: user, kind: 'monthly', metric: 'earnings', target_amount: 1_000, period_start: Date.new(2026, 6, 1),
                  period_end: Date.new(2026, 6, 30))
    create(:earning, user: user, date: Date.new(2026, 4, 10), amount: 1_200)
    create(:earning, user: user, date: Date.new(2026, 5, 10), amount: 400)
    create(:earning, user: user, date: Date.new(2026, 6, 10), amount: 1_200)

    count = described_class.new(goal: june).count

    expect(count).to eq(1)
  end

  it 'stops at a month with no goal' do
    create(:goal, user: user, kind: 'monthly', metric: 'earnings', target_amount: 1_000, period_start: Date.new(2026, 4, 1),
           period_end: Date.new(2026, 4, 30))
    june = create(:goal, user: user, kind: 'monthly', metric: 'earnings', target_amount: 1_000, period_start: Date.new(2026, 6, 1),
                  period_end: Date.new(2026, 6, 30))
    create(:earning, user: user, date: Date.new(2026, 4, 10), amount: 1_200)
    create(:earning, user: user, date: Date.new(2026, 6, 10), amount: 1_200)

    count = described_class.new(goal: june).count

    expect(count).to eq(1)
  end

  it 'judges each previous goal by its own metric' do
    create(:goal, user: user, kind: 'monthly', metric: 'profit', target_amount: 1_000, period_start: Date.new(2026, 5, 1),
           period_end: Date.new(2026, 5, 31))
    june = create(:goal, user: user, kind: 'monthly', metric: 'earnings', target_amount: 1_000, period_start: Date.new(2026, 6, 1),
                  period_end: Date.new(2026, 6, 30))
    create(:earning, user: user, date: Date.new(2026, 5, 10), amount: 1_200)
    create(:expense, user: user, date: Date.new(2026, 5, 12), amount: 500, paid: true)
    create(:earning, user: user, date: Date.new(2026, 6, 10), amount: 1_200)

    count = described_class.new(goal: june).count

    expect(count).to eq(1)
  end

  it 'ignores a previous goal of another kind' do
    create(:goal, user: user, kind: 'weekly', metric: 'earnings', target_amount: 100,
                  period_start: Date.new(2026, 5, 25), period_end: Date.new(2026, 5, 31))
    create(:earning, user: user, date: Date.new(2026, 5, 27), amount: 300)
    june = create(:goal, user: user, kind: 'monthly', metric: 'earnings', target_amount: 1_000, period_start: Date.new(2026, 6, 1),
                  period_end: Date.new(2026, 6, 30))
    create(:earning, user: user, date: Date.new(2026, 6, 10), amount: 1_200)

    count = described_class.new(goal: june).count

    expect(count).to eq(1)
  end
end
