require 'rails_helper'

RSpec.describe WeeklySummaries::Builder do
  let(:user) { create(:user) }
  let(:week) { Date.new(2026, 7, 6)..Date.new(2026, 7, 12) }

  describe '.for' do
    it 'normalizes any date to the monday that starts its week' do
      midweek_summary = described_class.for(user: user, week_start: '2026-07-09').call
      sunday_summary = described_class.for(user: user, week_start: '2026-07-12').call

      expect(midweek_summary.week).to eq(week)
      expect(sunday_summary.week).to eq(week)
    end

    it 'raises not found for a malformed week start' do
      expect { described_class.for(user: user, week_start: 'abc') }.to raise_error(ActiveRecord::RecordNotFound)
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

    it 'splits profit by weekday from monday to sunday' do
      create(:earning, user: user, date: Date.new(2026, 7, 6), amount: 300, trips_count: 10)
      create(:earning, user: user, date: Date.new(2026, 7, 10), amount: 500, trips_count: 12)
      create(:earning, user: user, date: Date.new(2026, 7, 10), amount: 100, trips_count: 3)
      create(:expense, user: user, date: Date.new(2026, 7, 8), amount: 150, paid: true)

      summary = described_class.new(user: user, week: week).call

      expect(summary.daily_profits).to eq([300, 0, -150, 0, 600, 0, 0])
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

    it 'reports the paid category with the highest total' do
      create(:expense, user: user, date: Date.new(2026, 7, 6), amount: 200, category: 'fuel', paid: true)
      create(:expense, user: user, date: Date.new(2026, 7, 8), amount: 112, category: 'fuel', paid: true)
      create(:expense, user: user, date: Date.new(2026, 7, 9), amount: 80, category: 'meals', paid: true)

      summary = described_class.new(user: user, week: week).call

      expect(summary.top_category).to eq(WeeklySummaries::Builder::TopCategory.new(key: 'fuel', amount: 312))
    end

    it 'breaks category ties by enum order' do
      create(:expense, user: user, date: Date.new(2026, 7, 6), amount: 100, category: 'maintenance', paid: true)
      create(:expense, user: user, date: Date.new(2026, 7, 7), amount: 100, category: 'fuel', paid: true)

      summary = described_class.new(user: user, week: week).call

      expect(summary.top_category.key).to eq('fuel')
    end

    it 'returns zeros and no highlights for an empty week' do
      summary = described_class.new(user: user, week: week).call

      expect(summary.profit).to eq(0)
      expect(summary.trips).to eq(0)
      expect(summary.days_worked).to eq(0)
      expect(summary.daily_profits).to eq([0, 0, 0, 0, 0, 0, 0])
      expect(summary.best_day_index).to be_nil
      expect(summary.top_category).to be_nil
      expect(summary.per_km).to be_nil
    end
  end
end
