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
               user:          user,
               kind:          'monthly',
               target_amount: 6000,
               period_start:  Date.new(2026, 6, 1),
               period_end:    Date.new(2026, 6, 30),
               metric:        'profit')
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

        expect(result[:monthly][:days_remaining]).to eq(16)
        expect(result[:monthly][:remaining_per_day].round(2)).to eq(281.25)
      end

      it 'flags on_track when projection reaches target' do
        create(:earning, user: user, date: Date.new(2026, 6, 10), amount: 5000)

        result = described_class.new(user: user, date: reference_date).call

        expect(result[:monthly][:on_track]).to be(true)
      end

      context 'when goal is reached' do
        before { create(:earning, user: user, date: Date.new(2026, 6, 4), amount: 5500) }

        it 'flags reached and exposes surplus' do
          result = described_class.new(user: user, date: reference_date).call

          expect(result[:monthly][:reached]).to be(true)
          expect(result[:monthly][:surplus]).to eq(1000)
        end

        it 'caps remaining_per_day at zero when reached' do
          result = described_class.new(user: user, date: reference_date).call

          expect(result[:monthly][:remaining_per_day]).to eq(0)
        end
      end

      context 'when days_elapsed is below MIN_DAYS_FOR_PROJECTION' do
        it 'returns nil projection and a tracking flag' do
          edge_service = described_class.new(user: user, date: Date.new(2026, 6, 1))

          result = edge_service.call

          expect(result[:monthly][:projection]).to be_nil
          expect(result[:monthly][:tracking]).to be(true)
        end
      end

      it 'computes daily_pace as current divided by days_elapsed' do
        result = described_class.new(user: user, date: reference_date).call

        expect(result[:monthly][:daily_pace].round(2)).to eq(100.00)
      end
    end

    context 'with a weekly goal' do
      let(:goal) do
        create(:goal,
               user:          user,
               kind:          'weekly',
               target_amount: 1400,
               period_start:  Date.new(2026, 6, 8),
               period_end:    Date.new(2026, 6, 14),
               metric:        'earnings')
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
               user:          user,
               kind:          'annual',
               target_amount: 80_000,
               period_start:  Date.new(2026, 1, 1),
               period_end:    Date.new(2026, 12, 31),
               metric:        'profit')
      end

      before { goal }

      it 'computes annual projection with days_remaining' do
        create(:earning, user: user, date: Date.new(2026, 3, 1), amount: 10_000)

        result = described_class.new(user: user, date: reference_date).call

        expect(result[:annual][:projection]).to be > 0
        expect(result[:annual][:days_remaining]).to eq(200)
      end
    end

    it 'delegates achievements to AchievementsService' do
      (Date.new(2026, 6, 9)..Date.new(2026, 6, 15)).each do |earning_date|
        create(:earning, user: user, date: earning_date, amount: 100)
      end

      result = described_class.new(user: user, date: reference_date).call

      expect(result[:achievements].map { |badge| badge[:type] }).to include(:streak)
    end

    context 'consistency with the dashboard profit for the same period' do
      it 'matches Dashboard::StatsService profit and ignores unpaid expenses' do
        create(:goal, user: user, kind: 'monthly', target_amount: 6000,
               period_start: Date.new(2026, 6, 1), period_end: Date.new(2026, 6, 30), metric: 'profit')
        create(:earning, user: user, date: Date.new(2026, 6, 5), amount: 2000)
        create(:expense, user: user, date: Date.new(2026, 6, 6), amount: 500, paid: true)
        create(:expense, user: user, date: Date.new(2026, 6, 7), amount: 300, paid: false)

        progress = described_class.new(user: user, date: reference_date).call
        stats = Dashboard::StatsService.new(year: 2026, month: 6, user: user).call

        expect(progress[:monthly][:current]).to eq(stats[:profit])
        expect(progress[:monthly][:current]).to eq(1500)
      end
    end
  end

  describe '#past_goals' do
    let(:user) { create(:user) }
    let(:reference_date) { Date.new(2026, 6, 30) }

    it 'returns past goals of the kind sorted by recency with achievement flag' do
      achieved_goal = create(:goal, user: user, kind: 'monthly', target_amount: 5000,
                             period_start: Date.new(2026, 4, 1), period_end: Date.new(2026, 4, 30))
      missed_goal = create(:goal, user: user, kind: 'monthly', target_amount: 5000,
                           period_start: Date.new(2026, 5, 1), period_end: Date.new(2026, 5, 31))
      create(:earning, user: user, date: Date.new(2026, 4, 15), amount: 6000)
      create(:earning, user: user, date: Date.new(2026, 5, 10), amount: 3000)

      result = described_class.new(user: user, date: reference_date).past_goals('monthly')

      expect(result.map { |row| row[:goal] }).to eq([missed_goal, achieved_goal])
      expect(result.find { |row| row[:goal] == achieved_goal }[:achieved]).to be(true)
      expect(result.find { |row| row[:goal] == missed_goal }[:achieved]).to be(false)
    end

    it 'excludes goals whose period_end is greater than or equal to date' do
      create(:goal, user: user, kind: 'monthly', target_amount: 5000,
             period_start: Date.new(2026, 6, 1), period_end: Date.new(2026, 6, 30))

      result = described_class.new(user: user, date: reference_date).past_goals('monthly')

      expect(result).to be_empty
    end

    it 'limits to the configured count' do
      7.times do |offset|
        month = Date.new(2025, 11, 1) + offset.months
        create(:goal, user: user, kind: 'monthly', target_amount: 1000,
               period_start: month.beginning_of_month, period_end: month.end_of_month)
      end

      result = described_class.new(user: user, date: reference_date).past_goals('monthly', limit: 3)

      expect(result.size).to eq(3)
    end
  end
end
