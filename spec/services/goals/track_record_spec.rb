require 'rails_helper'

RSpec.describe Goals::TrackRecord do
  let(:user) { create(:user) }
  let(:goal) { weekly_goal(Date.new(2026, 7, 6)) }

  def weekly_goal(monday, metric: 'earnings', owner: user)
    create(:goal, user: owner, kind: 'weekly', metric: metric, target_amount: 1_000,
                  period_start: monday, period_end: monday + 6)
  end

  def earn(date, amount)
    create(:earning, user: user, date: date, amount: amount)
  end

  it 'counts the hits among the four goals of the same kind before this one' do
    [Date.new(2026, 6, 1), Date.new(2026, 6, 8), Date.new(2026, 6, 15), Date.new(2026, 6, 29)].each do |monday|
      weekly_goal(monday)
    end
    weekly_goal(Date.new(2026, 5, 25))
    earn(Date.new(2026, 6, 2), 1_200)
    earn(Date.new(2026, 6, 9), 1_000)
    earn(Date.new(2026, 6, 16), 300)
    earn(Date.new(2026, 6, 30), 1_500)
    earn(Date.new(2026, 5, 26), 2_000)

    record = described_class.new(goal: goal).call

    expect(record).to have_attributes(hits: 3, total: 4)
  end

  it 'judges each previous goal by its own metric and calls half hit favorable' do
    weekly_goal(Date.new(2026, 6, 22), metric: 'profit')
    weekly_goal(Date.new(2026, 6, 29))
    earn(Date.new(2026, 6, 23), 1_200)
    create(:expense, user: user, date: Date.new(2026, 6, 24), amount: 300, paid: true)
    earn(Date.new(2026, 6, 30), 1_000)

    record = described_class.new(goal: goal).call

    expect(record).to have_attributes(hits: 1, total: 2)
  end

  it 'reports nothing with a single previous goal' do
    weekly_goal(Date.new(2026, 6, 29))
    earn(Date.new(2026, 6, 30), 1_500)

    record = described_class.new(goal: goal).call

    expect(record).to be_nil
  end

  it 'reports nothing when fewer than half of the previous goals were hit' do
    [Date.new(2026, 6, 15), Date.new(2026, 6, 22), Date.new(2026, 6, 29)].each { |monday| weekly_goal(monday) }
    earn(Date.new(2026, 6, 30), 1_500)

    record = described_class.new(goal: goal).call

    expect(record).to be_nil
  end

  it 'ignores goals of another kind and of another user' do
    weekly_goal(Date.new(2026, 6, 22))
    weekly_goal(Date.new(2026, 6, 29))
    weekly_goal(Date.new(2026, 6, 15), owner: create(:user))
    create(:goal, user: user, kind: 'monthly', metric: 'earnings', target_amount: 100,
                  period_start: Date.new(2026, 6, 1), period_end: Date.new(2026, 6, 30))
    earn(Date.new(2026, 6, 23), 1_000)

    record = described_class.new(goal: goal).call

    expect(record).to have_attributes(hits: 1, total: 2)
  end
end
