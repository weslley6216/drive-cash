require 'rails_helper'

RSpec.describe WeeklySummaries::Builder do
  let(:user) { create(:user) }
  let(:week) { Calendars::Week.containing(Date.new(2026, 7, 6)) }

  describe '.for' do
    it 'normalizes any date to the week that contains it' do
      midweek_summary = described_class.for(user: user, week_start: '2026-07-09').call
      sunday_summary = described_class.for(user: user, week_start: '2026-07-12').call

      expect(midweek_summary.week).to eq(week)
      expect(sunday_summary.week).to eq(week)
    end

    it 'raises not found for a malformed week start' do
      expect { described_class.for(user: user, week_start: 'abc') }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'raises not found for a future week and opens the current one' do
      travel_to Time.zone.local(2026, 7, 14, 10, 0)

      current_summary = described_class.for(user: user, week_start: '2026-07-13').call

      expect(current_summary.week).to eq(Calendars::Week.containing(Date.new(2026, 7, 13)))
      expect { described_class.for(user: user, week_start: '2026-07-20') }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe '#call' do
    it 'sums profit, trips and worked days of the week' do
      create(:earning, user: user, date: Date.new(2026, 7, 6), amount: 300, trips_count: 10)
      create(:earning, user: user, date: Date.new(2026, 7, 10), amount: 500, trips_count: 12)
      create(:earning, user: user, date: Date.new(2026, 7, 10), amount: 100, trips_count: 3)
      create(:expense, user: user, date: Date.new(2026, 7, 8), amount: 150, paid: true)
      create(:expense, user: user, date: Date.new(2026, 7, 8), amount: 999, paid: false)

      summary = described_class.new(user: user, week: week).call

      expect(summary.profit).to eq(750)
      expect(summary.trips).to eq(25)
      expect(summary.days_worked).to eq(2)
    end

    it 'sums earnings and paid expenses of the week' do
      create(:earning, user: user, date: Date.new(2026, 7, 6), amount: 300, trips_count: 10)
      create(:earning, user: user, date: Date.new(2026, 7, 10), amount: 600, trips_count: 12)
      create(:expense, user: user, date: Date.new(2026, 7, 8), amount: 150, paid: true)
      create(:expense, user: user, date: Date.new(2026, 7, 8), amount: 999, paid: false)

      summary = described_class.new(user: user, week: week).call

      expect(summary.earnings_total).to eq(900)
      expect(summary.expenses_total).to eq(150)
    end

    it 'ignores records outside the week' do
      create(:earning, user: user, date: Date.new(2026, 7, 5), amount: 300, trips_count: 10)
      create(:earning, user: user, date: Date.new(2026, 7, 13), amount: 500, trips_count: 12)

      summary = described_class.new(user: user, week: week).call

      expect(summary.profit).to eq(0)
      expect(summary.trips).to eq(0)
      expect(summary.days_worked).to eq(0)
    end

    it 'ignores records from other users' do
      create(:earning, date: Date.new(2026, 7, 6), amount: 300, trips_count: 10)

      summary = described_class.new(user: user, week: week).call

      expect(summary.profit).to eq(0)
    end

    it 'breaks the week into days from monday to sunday with profit, earnings, paid expenses and trips' do
      create(:earning, user: user, date: Date.new(2026, 7, 6), amount: 300, trips_count: 10)
      create(:earning, user: user, date: Date.new(2026, 7, 10), amount: 500, trips_count: 12)
      create(:earning, user: user, date: Date.new(2026, 7, 10), amount: 100, trips_count: 3)
      create(:expense, user: user, date: Date.new(2026, 7, 8), amount: 150, paid: true)
      create(:expense, user: user, date: Date.new(2026, 7, 8), amount: 999, paid: false)

      summary = described_class.new(user: user, week: week).call

      expect(summary.days.map(&:date)).to eq(week.range.to_a)
      expect(summary.days.map(&:profit)).to eq([300, 0, -150, 0, 600, 0, 0])
      expect(summary.days[4]).to have_attributes(earnings: 600, expenses: 0, trips: 15, empty: false, future: false)
      expect(summary.days[2]).to have_attributes(earnings: 0, expenses: 150, trips: 0, empty: false)
      expect(summary.days[1]).to have_attributes(earnings: 0, expenses: 0, trips: 0, empty: true)
    end

    it 'keeps a day with only a pending expense out of the empty days with zeroed values' do
      create(:expense, user: user, date: Date.new(2026, 7, 9), amount: 80, paid: false)

      summary = described_class.new(user: user, week: week).call

      expect(summary.days[3]).to have_attributes(profit: 0, earnings: 0, expenses: 0, trips: 0, empty: false)
    end

    it 'marks the days after today as future in the current week' do
      travel_to Time.zone.local(2026, 7, 8, 10, 0)

      summary = described_class.new(user: user, week: week).call

      expect(summary.days.map(&:future)).to eq([false, false, false, true, true, true, true])
    end

    it 'picks the day with the highest positive profit as best' do
      create(:earning, user: user, date: Date.new(2026, 7, 6), amount: 300, trips_count: 10)
      create(:earning, user: user, date: Date.new(2026, 7, 10), amount: 600, trips_count: 12)

      summary = described_class.new(user: user, week: week).call

      expect(summary.best_day_index).to eq(4)
    end

    it 'picks the first day when two days tie' do
      create(:earning, user: user, date: Date.new(2026, 7, 6), amount: 200, trips_count: 10)
      create(:earning, user: user, date: Date.new(2026, 7, 9), amount: 200, trips_count: 12)

      summary = described_class.new(user: user, week: week).call

      expect(summary.best_day_index).to eq(0)
    end

    it 'has no best day when no day is profitable' do
      create(:expense, user: user, date: Date.new(2026, 7, 8), amount: 150, paid: true)

      summary = described_class.new(user: user, week: week).call

      expect(summary.best_day_index).to be_nil
    end

    it 'divides profit by the odometer delta of the week' do
      vehicle = create(:vehicle, user: user)
      create(:refueling, vehicle: vehicle, date: Date.new(2026, 7, 6), odometer_km: 10_000)
      create(:refueling, vehicle: vehicle, date: Date.new(2026, 7, 12), odometer_km: 10_500)
      create(:earning, user: user, date: Date.new(2026, 7, 6), amount: 1_000, trips_count: 10)

      summary = described_class.new(user: user, week: week).call

      expect(summary.per_km).to eq(2)
    end

    it 'leaves per km empty without two odometer readings' do
      vehicle = create(:vehicle, user: user)
      create(:refueling, vehicle: vehicle, date: Date.new(2026, 7, 6), odometer_km: 10_000)

      summary = described_class.new(user: user, week: week).call

      expect(summary.per_km).to be_nil
    end

    it 'ranks the three paid categories with the highest totals' do
      create(:expense, user: user, date: Date.new(2026, 7, 6), amount: 200, category: 'fuel', paid: true)
      create(:expense, user: user, date: Date.new(2026, 7, 8), amount: 112, category: 'fuel', paid: true)
      create(:expense, user: user, date: Date.new(2026, 7, 9), amount: 80, category: 'meals', paid: true)
      create(:expense, user: user, date: Date.new(2026, 7, 9), amount: 64, category: 'toll', paid: true)
      create(:expense, user: user, date: Date.new(2026, 7, 10), amount: 10, category: 'parking', paid: true)
      create(:expense, user: user, date: Date.new(2026, 7, 10), amount: 999, category: 'maintenance', paid: false)

      summary = described_class.new(user: user, week: week).call

      expect(summary.top_categories).to eq(
        [
          WeeklySummaries::Builder::TopCategory.new(key: 'fuel', amount: 312),
          WeeklySummaries::Builder::TopCategory.new(key: 'meals', amount: 80),
          WeeklySummaries::Builder::TopCategory.new(key: 'toll', amount: 64)
        ]
      )
    end

    it 'breaks category ties by enum order' do
      create(:expense, user: user, date: Date.new(2026, 7, 6), amount: 100, category: 'maintenance', paid: true)
      create(:expense, user: user, date: Date.new(2026, 7, 7), amount: 100, category: 'fuel', paid: true)

      summary = described_class.new(user: user, week: week).call

      expect(summary.top_categories.map(&:key)).to eq(%w[fuel maintenance])
    end

    context 'with a weekly goal' do
      before do
        create(:earning, user: user, date: Date.new(2026, 7, 6), amount: 900, trips_count: 10)
        create(:expense, user: user, date: Date.new(2026, 7, 8), amount: 150, paid: true)
      end

      it 'measures a profit goal below its target' do
        goal = create(:goal, user: user, kind: 'weekly', metric: 'profit', target_amount: 1_000,
                             period_start: Date.new(2026, 7, 6), period_end: Date.new(2026, 7, 12))

        summary = described_class.new(user: user, week: week).call

        expect(summary.goal).to have_attributes(goal: goal, achieved: 750, percent: 75, hit: false)
      end

      it 'marks a goal reached from its target on' do
        create(:goal, user: user, kind: 'weekly', metric: 'profit', target_amount: 700,
                      period_start: Date.new(2026, 7, 6), period_end: Date.new(2026, 7, 12))

        summary = described_class.new(user: user, week: week).call

        expect(summary.goal).to have_attributes(achieved: 750, percent: 107, hit: true)
      end

      it 'measures an earnings goal by the earnings only' do
        create(:goal, user: user, kind: 'weekly', metric: 'earnings', target_amount: 1_000,
                      period_start: Date.new(2026, 7, 6), period_end: Date.new(2026, 7, 12))

        summary = described_class.new(user: user, week: week).call

        expect(summary.goal).to have_attributes(achieved: 900, percent: 90, hit: false)
      end

      it 'has no goal without a weekly goal starting on the monday' do
        create(:goal, user: user, kind: 'monthly', period_start: Date.new(2026, 7, 1), period_end: Date.new(2026, 7, 31))
        create(:goal, user: user, kind: 'weekly', period_start: Date.new(2026, 7, 13), period_end: Date.new(2026, 7, 19))
        create(:goal, kind: 'weekly', period_start: Date.new(2026, 7, 6), period_end: Date.new(2026, 7, 12))

        summary = described_class.new(user: user, week: week).call

        expect(summary.goal).to be_nil
      end
    end

    it 'lists the days without any earning or expense, paid or not' do
      create(:earning, user: user, date: Date.new(2026, 7, 6), amount: 300, trips_count: 10)
      create(:earning, user: user, date: Date.new(2026, 7, 10), amount: 500, trips_count: 12)
      create(:expense, user: user, date: Date.new(2026, 7, 8), amount: 999, paid: false)

      summary = described_class.new(user: user, week: week).call

      expect(summary.empty_days).to eq([Date.new(2026, 7, 7), Date.new(2026, 7, 9), Date.new(2026, 7, 11), Date.new(2026, 7, 12)])
      expect(summary.blank_week).to be(false)
    end

    it 'leaves the days after today out of the empty days of the current week' do
      travel_to Time.zone.local(2026, 7, 8, 10, 0)
      create(:earning, user: user, date: Date.new(2026, 7, 6), amount: 300, trips_count: 10)

      summary = described_class.new(user: user, week: week).call

      expect(summary.empty_days).to eq([Date.new(2026, 7, 7), Date.new(2026, 7, 8)])
    end

    it 'returns zeros and no highlights for an empty week' do
      summary = described_class.new(user: user, week: week).call

      expect(summary.profit).to eq(0)
      expect(summary.earnings_total).to eq(0)
      expect(summary.expenses_total).to eq(0)
      expect(summary.trips).to eq(0)
      expect(summary.days_worked).to eq(0)
      expect(summary.days.map(&:profit)).to eq([0, 0, 0, 0, 0, 0, 0])
      expect(summary.best_day_index).to be_nil
      expect(summary.top_categories).to eq([])
      expect(summary.goal).to be_nil
      expect(summary.per_km).to be_nil
      expect(summary.empty_days).to eq(week.range.to_a)
      expect(summary.blank_week).to be(true)
    end
  end
end
