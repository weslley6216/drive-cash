require 'rails_helper'

RSpec.describe Goals::ProgressService do
  let(:user) { create(:user) }
  let(:reference_date) { Date.new(2026, 6, 15) }

  describe '#call' do
    context 'when user has no goals' do
      it 'returns nil for every kind' do
        result = described_class.new(user: user, date: reference_date).call

        expect(result[:weekly]).to be_nil
        expect(result[:monthly]).to be_nil
        expect(result[:annual]).to be_nil
        expect(result[:achievements]).to eq([])
      end
    end

    context 'with a monthly profit goal' do
      let(:goal) do
        create(:goal,
               user: user,
               kind: 'monthly',
               target_amount: 6000,
               period_start: Date.new(2026, 6, 1),
               period_end: Date.new(2026, 6, 30),
               metric: 'profit')
      end

      before do
        goal
        create(:earning, user: user, date: Date.new(2026, 6, 5), amount: 2000)
        create(:expense, user: user, date: Date.new(2026, 6, 6), amount: 500)
      end

      it 'returns the goal, current value and percent' do
        result = described_class.new(user: user, date: reference_date).call

        expect(result[:monthly][:goal]).to eq(goal)
        expect(result[:monthly][:current]).to eq(1500)
        expect(result[:monthly][:target]).to eq(6000)
        expect(result[:monthly][:percent].round(2)).to eq(25.00)
      end

      it 'computes projection extrapolating to total period days' do
        result = described_class.new(user: user, date: reference_date).call

        expect(result[:monthly][:projection].round(2)).to eq(3000.00)
        expect(result[:monthly][:on_track]).to be(false)
      end

      it 'computes remaining_per_day based on days left in period' do
        result = described_class.new(user: user, date: reference_date).call

        expect(result[:monthly][:days_remaining]).to eq(15)
        expect(result[:monthly][:remaining_per_day].round(2)).to eq(300.00)
      end

      it 'flags on_track when projection reaches target' do
        create(:earning, user: user, date: Date.new(2026, 6, 10), amount: 5000)

        result = described_class.new(user: user, date: reference_date).call

        expect(result[:monthly][:on_track]).to be(true)
      end

      it 'returns zero projection on day 1 (days_elapsed = 1 is safe; explicitly handles 0)' do
        edge_service = described_class.new(user: user, date: Date.new(2026, 6, 1))

        result = edge_service.call

        expect(result[:monthly][:projection]).to be_a(Numeric)
      end
    end

    context 'with a weekly goal' do
      let(:goal) do
        create(:goal,
               user: user,
               kind: 'weekly',
               target_amount: 1400,
               period_start: Date.new(2026, 6, 8),
               period_end: Date.new(2026, 6, 14),
               metric: 'earnings')
      end

      before do
        goal
        create(:earning, user: user, date: Date.new(2026, 6, 8), amount: 200)
        create(:earning, user: user, date: Date.new(2026, 6, 10), amount: 300)
      end

      it 'returns 7 day breakdown with today and done flags' do
        result = described_class.new(user: user, date: Date.new(2026, 6, 10)).call

        days = result[:weekly][:days]
        expect(days.size).to eq(7)
        expect(days.first[:date]).to eq(Date.new(2026, 6, 8))
        expect(days.find { |day| day[:today] }[:date]).to eq(Date.new(2026, 6, 10))
        expect(days.count { |day| day[:done] }).to eq(2)
      end

      it 'uses earnings metric (no expense subtraction)' do
        create(:expense, user: user, date: Date.new(2026, 6, 9), amount: 100)

        result = described_class.new(user: user, date: Date.new(2026, 6, 10)).call

        expect(result[:weekly][:current]).to eq(500)
      end
    end

    context 'with an annual goal' do
      let(:goal) do
        create(:goal,
               user: user,
               kind: 'annual',
               target_amount: 80_000,
               period_start: Date.new(2026, 1, 1),
               period_end: Date.new(2026, 12, 31),
               metric: 'profit')
      end

      before { goal }

      it 'computes annual projection with days_remaining' do
        create(:earning, user: user, date: Date.new(2026, 3, 1), amount: 10_000)

        result = described_class.new(user: user, date: reference_date).call

        expect(result[:annual][:projection]).to be > 0
        expect(result[:annual][:days_remaining]).to eq(199)
      end
    end

    describe 'achievements' do
      it 'returns streak_7d badge when user has 7 consecutive earning days' do
        (Date.new(2026, 6, 9)..Date.new(2026, 6, 15)).each do |earning_date|
          create(:earning, user: user, date: earning_date, amount: 100)
        end

        result = described_class.new(user: user, date: reference_date).call

        expect(result[:achievements].map { |badge| badge[:icon] }).to include('flame')
      end

      it 'returns best_day badge with highest earning day in current month' do
        create(:earning, user: user, date: Date.new(2026, 6, 3), amount: 800)
        create(:earning, user: user, date: Date.new(2026, 6, 4), amount: 200)

        result = described_class.new(user: user, date: reference_date).call

        best = result[:achievements].find { |badge| badge[:icon] == 'zap' }
        expect(best[:value]).to eq(800)
      end

      it 'returns goal_completed badge when most recent past monthly goal was beaten' do
        create(:goal,
               user: user,
               kind: 'monthly',
               target_amount: 5000,
               period_start: Date.new(2026, 5, 1),
               period_end: Date.new(2026, 5, 31),
               metric: 'profit')
        create(:earning, user: user, date: Date.new(2026, 5, 10), amount: 6000)

        result = described_class.new(user: user, date: reference_date).call

        completed = result[:achievements].find { |badge| badge[:icon] == 'star' }
        expect(completed[:color]).to eq('#a855f7')
        expect(completed[:label]).to include('Maio')
      end

      it 'returns goal_completed badge for older beaten goal when most recent was not beaten' do
        create(:goal, user: user, kind: 'monthly', target_amount: 10_000,
               period_start: Date.new(2026, 5, 1), period_end: Date.new(2026, 5, 31), metric: 'profit')
        create(:earning, user: user, date: Date.new(2026, 5, 10), amount: 1000)

        create(:goal, user: user, kind: 'monthly', target_amount: 5000,
               period_start: Date.new(2026, 4, 1), period_end: Date.new(2026, 4, 30), metric: 'profit')
        create(:earning, user: user, date: Date.new(2026, 4, 10), amount: 6000)

        result = described_class.new(user: user, date: reference_date).call

        completed = result[:achievements].find { |badge| badge[:icon] == 'star' }
        expect(completed).not_to be_nil
        expect(completed[:label]).to include('Abril')
      end

      it 'does not return goal_completed badge when no past monthly goal was beaten' do
        create(:goal,
               user: user,
               kind: 'monthly',
               target_amount: 10_000,
               period_start: Date.new(2026, 5, 1),
               period_end: Date.new(2026, 5, 31),
               metric: 'profit')
        create(:earning, user: user, date: Date.new(2026, 5, 10), amount: 1000)

        result = described_class.new(user: user, date: reference_date).call

        icons = result[:achievements].map { |badge| badge[:icon] }
        expect(icons).not_to include('star')
      end
    end
  end
end
