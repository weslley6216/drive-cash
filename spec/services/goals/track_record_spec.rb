require 'rails_helper'

RSpec.describe Goals::TrackRecord do
  let(:user) { create(:user) }
  let(:goal) do
    create(:goal, user: user, kind: 'weekly', metric: 'earnings', target_amount: 1_000,
                  period_start: Date.new(2026, 7, 6), period_end: Date.new(2026, 7, 12))
  end

  it 'counts the hits among the four goals of the same kind before this one' do
    [Date.new(2026, 6, 1), Date.new(2026, 6, 8), Date.new(2026, 6, 15), Date.new(2026, 6, 29)].each do |monday|
      create(:goal, user: user, kind: 'weekly', metric: 'earnings', target_amount: 1_000, period_start: monday, period_end: monday + 6)
    end
    create(:goal, user: user, kind: 'weekly', metric: 'earnings', target_amount: 1_000, period_start: Date.new(2026, 5, 25),
           period_end: Date.new(2026, 5, 31))
    create(:earning, user: user, date: Date.new(2026, 6, 2), amount: 1_200)
    create(:earning, user: user, date: Date.new(2026, 6, 9), amount: 1_000)
    create(:earning, user: user, date: Date.new(2026, 6, 16), amount: 300)
    create(:earning, user: user, date: Date.new(2026, 6, 30), amount: 1_500)
    create(:earning, user: user, date: Date.new(2026, 5, 26), amount: 2_000)

    record = described_class.new(goal: goal).call

    expect(record).to have_attributes(hits: 3, total: 4)
  end

  it 'judges each previous goal by its own metric and calls half hit favorable' do
    create(:goal, user: user, kind: 'weekly', metric: 'profit', target_amount: 1_000, period_start: Date.new(2026, 6, 22),
           period_end: Date.new(2026, 6, 28))
    create(:goal, user: user, kind: 'weekly', metric: 'earnings', target_amount: 1_000, period_start: Date.new(2026, 6, 29),
           period_end: Date.new(2026, 7, 5))
    create(:earning, user: user, date: Date.new(2026, 6, 23), amount: 1_200)
    create(:expense, user: user, date: Date.new(2026, 6, 24), amount: 300, paid: true)
    create(:earning, user: user, date: Date.new(2026, 6, 30), amount: 1_000)

    record = described_class.new(goal: goal).call

    expect(record).to have_attributes(hits: 1, total: 2)
  end

  it 'reports nothing with a single previous goal' do
    create(:goal, user: user, kind: 'weekly', metric: 'earnings', target_amount: 1_000, period_start: Date.new(2026, 6, 29),
           period_end: Date.new(2026, 7, 5))
    create(:earning, user: user, date: Date.new(2026, 6, 30), amount: 1_500)

    record = described_class.new(goal: goal).call

    expect(record).to be_nil
  end

  it 'reports nothing when fewer than half of the previous goals were hit' do
    [Date.new(2026, 6, 15), Date.new(2026, 6, 22), Date.new(2026, 6, 29)].each do |monday|
      create(:goal, user: user, kind: 'weekly', metric: 'earnings', target_amount: 1_000, period_start: monday, period_end: monday + 6)
    end
    create(:earning, user: user, date: Date.new(2026, 6, 30), amount: 1_500)

    record = described_class.new(goal: goal).call

    expect(record).to be_nil
  end

  it 'ignores goals of another kind and of another user' do
    create(:goal, user: user, kind: 'weekly', metric: 'earnings', target_amount: 1_000, period_start: Date.new(2026, 6, 22),
           period_end: Date.new(2026, 6, 28))
    create(:goal, user: user, kind: 'weekly', metric: 'earnings', target_amount: 1_000, period_start: Date.new(2026, 6, 29),
           period_end: Date.new(2026, 7, 5))
    create(:goal, user: create(:user), kind: 'weekly', metric: 'earnings', target_amount: 1_000, period_start: Date.new(2026, 6, 15),
           period_end: Date.new(2026, 6, 21))
    create(:goal, user: user, kind: 'monthly', metric: 'earnings', target_amount: 100,
                  period_start: Date.new(2026, 6, 1), period_end: Date.new(2026, 6, 30))
    create(:earning, user: user, date: Date.new(2026, 6, 23), amount: 1_000)

    record = described_class.new(goal: goal).call

    expect(record).to have_attributes(hits: 1, total: 2)
  end
end
