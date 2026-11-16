require 'rails_helper'

RSpec.describe Goals::AchievementsService do
  let(:user) { create(:user) }
  let(:reference_date) { Date.new(2026, 6, 15) }

  describe '#call' do
    it 'returns no badges when the user has no activity' do
      result = described_class.new(user: user, date: reference_date).call

      expect(result).to eq([])
    end

    it 'returns the streak length when user has 7 consecutive earning days' do
      (Date.new(2026, 6, 9)..Date.new(2026, 6, 15)).each do |earning_date|
        create(:earning, user: user, date: earning_date, amount: 100)
      end

      result = described_class.new(user: user, date: reference_date).call

      expect(result).to include(type: :streak, days: 7)
    end

    it 'returns the value and the date of the highest earning day in current month' do
      create(:earning, user: user, date: Date.new(2026, 6, 3), amount: 800)
      create(:earning, user: user, date: Date.new(2026, 6, 4), amount: 200)

      result = described_class.new(user: user, date: reference_date).call

      best = result.find { |badge| badge[:type] == :best_day }
      expect(best).to eq(type: :best_day, value: 800, date: Date.new(2026, 6, 3))
    end

    it 'returns goal_completed badge when most recent past monthly goal was beaten' do
      create(:goal,
             user:          user,
             kind:          'monthly',
             target_amount: 5000,
             period_start:  Date.new(2026, 5, 1),
             period_end:    Date.new(2026, 5, 31),
             metric:        'profit')
      create(:earning, user: user, date: Date.new(2026, 5, 10), amount: 6000)

      result = described_class.new(user: user, date: reference_date).call

      completed = result.find { |badge| badge[:type] == :goal_completed }
      expect(completed).to eq(type: :goal_completed, period_start: Date.new(2026, 5, 1), percent: 120)
    end

    it 'returns goal_completed badge for older beaten goal when most recent was not beaten' do
      create(:goal, user: user, kind: 'monthly', target_amount: 10_000,
             period_start: Date.new(2026, 5, 1), period_end: Date.new(2026, 5, 31), metric: 'profit')
      create(:earning, user: user, date: Date.new(2026, 5, 10), amount: 1000)

      create(:goal, user: user, kind: 'monthly', target_amount: 5000,
             period_start: Date.new(2026, 4, 1), period_end: Date.new(2026, 4, 30), metric: 'profit')
      create(:earning, user: user, date: Date.new(2026, 4, 10), amount: 6000)

      result = described_class.new(user: user, date: reference_date).call

      completed = result.find { |badge| badge[:type] == :goal_completed }
      expect(completed).to eq(type: :goal_completed, period_start: Date.new(2026, 4, 1), percent: 120)
    end

    it 'ignores unpaid expenses when deciding if a past monthly goal was beaten' do
      create(:goal, user: user, kind: 'monthly', target_amount: 5000,
             period_start: Date.new(2026, 5, 1), period_end: Date.new(2026, 5, 31), metric: 'profit')
      create(:earning, user: user, date: Date.new(2026, 5, 10), amount: 6000)
      create(:expense, user: user, date: Date.new(2026, 5, 11), amount: 2000, paid: false)

      result = described_class.new(user: user, date: reference_date).call

      completed = result.find { |badge| badge[:type] == :goal_completed }
      expect(completed).to eq(type: :goal_completed, period_start: Date.new(2026, 5, 1), percent: 120)
    end

    it 'does not return goal_completed badge when no past monthly goal was beaten' do
      create(:goal,
             user:          user,
             kind:          'monthly',
             target_amount: 10_000,
             period_start:  Date.new(2026, 5, 1),
             period_end:    Date.new(2026, 5, 31),
             metric:        'profit')
      create(:earning, user: user, date: Date.new(2026, 5, 10), amount: 1000)

      result = described_class.new(user: user, date: reference_date).call

      types = result.map { |badge| badge[:type] }
      expect(types).not_to include(:goal_completed)
    end

    it 'ignores activity and goals of other users' do
      other_user = create(:user)
      (Date.new(2026, 6, 9)..Date.new(2026, 6, 15)).each do |earning_date|
        create(:earning, user: other_user, date: earning_date, amount: 100)
      end
      create(:goal, user: other_user, kind: 'monthly', target_amount: 500,
             period_start: Date.new(2026, 5, 1), period_end: Date.new(2026, 5, 31), metric: 'profit')
      create(:earning, user: other_user, date: Date.new(2026, 5, 10), amount: 600)

      result = described_class.new(user: user, date: reference_date).call

      expect(result).to eq([])
    end
  end
end
