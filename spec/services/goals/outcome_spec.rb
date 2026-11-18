require 'rails_helper'

RSpec.describe Goals::Outcome do
  let(:user) { create(:user) }
  let(:metric) { 'profit' }
  let(:target) { 1_000 }
  let(:date) { Date.new(2026, 7, 2) }
  let(:goal) do
    create(:goal, user: user, kind: 'monthly', metric: metric, target_amount: target,
                  period_start: Date.new(2026, 6, 1), period_end: Date.new(2026, 6, 30))
  end
  let(:outcome) { described_class.new(goal: goal, date: date).call }

  before do
    create(:earning, user: user, date: Date.new(2026, 6, 3), amount: 300)
    create(:earning, user: user, date: Date.new(2026, 6, 14), amount: 600)
    create(:expense, user: user, date: Date.new(2026, 6, 14), amount: 100, paid: true)
    create(:earning, user: user, date: Date.new(2026, 6, 20), amount: 450)
    create(:earning, user: user, date: Date.new(2026, 6, 27), amount: 70)
    create(:expense, user: user, date: Date.new(2026, 6, 27), amount: 500, paid: false)
    create(:earning, date: Date.new(2026, 6, 3), amount: 9_000)
  end

  it 'sums the paid result of the goal against its target' do
    expect(outcome).to have_attributes(target: 1_000, achieved: 1_320, surplus: 320, percent: 132)
  end

  it 'dates the first day the running result reaches the target' do
    expect(outcome).to have_attributes(hit_on: Date.new(2026, 6, 20), days_before_end: 10)
  end

  it 'counts the worked days and the result per worked day' do
    expect(outcome).to have_attributes(worked_days: 4, per_day: 330)
  end

  it 'picks the best day by the goal metric' do
    expect(outcome.best_day).to have_attributes(date: Date.new(2026, 6, 14), value: 500)
  end

  it 'suggests the result plus five percent rounded up to the next hundred' do
    expect(outcome.suggestion).to eq(1_400)
  end

  it 'offers the period after the goal with no goal there yet' do
    expect(outcome).to have_attributes(next_period: Date.new(2026, 7, 1)..Date.new(2026, 7, 31), next_goal: nil)
  end

  it 'carries the goal already created for the next period' do
    july = create(:goal, user: user, kind: 'monthly', period_start: Date.new(2026, 7, 1),
                         period_end: Date.new(2026, 7, 31))

    expect(outcome.next_goal).to eq(july)
  end

  context 'when the next period has already ended' do
    let(:date) { Date.new(2026, 8, 5) }

    it 'drops the next period' do
      expect(outcome).to have_attributes(next_period: nil, next_goal: nil)
    end
  end

  it 'carries the streak of hit periods in a row' do
    create(:goal, user: user, kind: 'monthly', metric: 'earnings', target_amount: 100,
                  period_start: Date.new(2026, 5, 1), period_end: Date.new(2026, 5, 31))
    create(:earning, user: user, date: Date.new(2026, 5, 8), amount: 200)

    expect(outcome.streak).to eq(2)
  end

  context 'with an earnings goal' do
    let(:metric) { 'earnings' }

    it 'measures gross earnings and the best earning day' do
      expect(outcome.achieved).to eq(1_420)
      expect(outcome.best_day).to have_attributes(date: Date.new(2026, 6, 14), value: 600)
    end
  end

  context 'when the result is short of the target' do
    let(:target) { 5_000 }

    it 'returns no outcome' do
      expect(outcome).to be_nil
    end
  end
end
