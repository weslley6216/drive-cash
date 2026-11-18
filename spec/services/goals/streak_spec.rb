require 'rails_helper'

RSpec.describe Goals::Streak do
  let(:user) { create(:user) }

  def monthly_goal(month, metric: 'earnings')
    start = Date.new(2026, month, 1)
    create(:goal, user: user, kind: 'monthly', metric: metric, target_amount: 1_000,
                  period_start: start, period_end: start.end_of_month)
  end

  def earn(month, amount)
    create(:earning, user: user, date: Date.new(2026, month, 10), amount: amount)
  end

  it 'counts the goal itself and every adjacent previous goal that was hit' do
    monthly_goal(4)
    monthly_goal(5)
    june = monthly_goal(6)
    [4, 5, 6].each { |month| earn(month, 1_200) }

    count = described_class.new(goal: june).count

    expect(count).to eq(3)
  end

  it 'stops at a previous goal that was missed' do
    monthly_goal(4)
    monthly_goal(5)
    june = monthly_goal(6)
    earn(4, 1_200)
    earn(5, 400)
    earn(6, 1_200)

    count = described_class.new(goal: june).count

    expect(count).to eq(1)
  end

  it 'stops at a month with no goal' do
    monthly_goal(4)
    june = monthly_goal(6)
    earn(4, 1_200)
    earn(6, 1_200)

    count = described_class.new(goal: june).count

    expect(count).to eq(1)
  end

  it 'judges each previous goal by its own metric' do
    monthly_goal(5, metric: 'profit')
    june = monthly_goal(6)
    earn(5, 1_200)
    create(:expense, user: user, date: Date.new(2026, 5, 12), amount: 500, paid: true)
    earn(6, 1_200)

    count = described_class.new(goal: june).count

    expect(count).to eq(1)
  end

  it 'ignores a previous goal of another kind' do
    create(:goal, user: user, kind: 'weekly', metric: 'earnings', target_amount: 100,
                  period_start: Date.new(2026, 5, 25), period_end: Date.new(2026, 5, 31))
    create(:earning, user: user, date: Date.new(2026, 5, 27), amount: 300)
    june = monthly_goal(6)
    earn(6, 1_200)

    count = described_class.new(goal: june).count

    expect(count).to eq(1)
  end
end
