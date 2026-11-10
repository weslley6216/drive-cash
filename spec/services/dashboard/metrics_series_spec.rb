require 'rails_helper'

RSpec.describe Dashboard::MetricsSeries do
  let(:user) { create(:user) }

  describe '#call' do
    it 'returns one point per month with earnings, in month order' do
      create(:earning, user: user, date: '2025-01-10', amount: 100.00)
      create(:earning, user: user, date: '2025-03-10', amount: 100.00)
      create(:earning, user: user, date: '2025-05-10', amount: 100.00)

      result = described_class.new(user: user, year: 2025).call

      expect(result[:per_day][:points].map { |point| point[:month] }).to eq([1, 3, 5])
    end

    it 'computes each metric from the month own earnings, expenses, trips and days' do
      create(:earning, user: user, date: '2025-03-10', amount: 600.00, trips_count: 5)
      create(:earning, user: user, date: '2025-03-20', amount: 400.00, trips_count: 5)
      create(:expense, user: user, date: '2025-03-15', amount: 200.00, paid: true)

      result = described_class.new(user: user, year: 2025).call
      march = result[:per_day][:points].find { |point| point[:month] == 3 }
      march_trip = result[:per_trip][:points].find { |point| point[:month] == 3 }
      march_margin = result[:margin][:points].find { |point| point[:month] == 3 }

      expect(march[:value]).to eq(400.0)
      expect(march_trip[:value]).to eq(80.0)
      expect(march_margin[:value]).to eq(80.0)
    end

    it 'stops at the filtered month' do
      (1..6).each { |month| create(:earning, user: user, date: Date.new(2025, month, 10), amount: 100.00) }

      result = described_class.new(user: user, year: 2025, month: 4).call

      expect(result[:per_day][:points].map { |point| point[:month] }).to eq([1, 2, 3, 4])
    end

    it 'covers every month of the year when no month is filtered' do
      create(:earning, user: user, date: '2025-02-10', amount: 100.00)
      create(:earning, user: user, date: '2025-11-10', amount: 100.00)

      result = described_class.new(user: user, year: 2025).call

      expect(result[:per_day][:points].map { |point| point[:month] }).to eq([2, 11])
    end

    it 'leaves out months with expenses but no earnings' do
      create(:expense, user: user, date: '2025-02-10', amount: 50.00, paid: true)
      create(:earning, user: user, date: '2025-01-10', amount: 100.00)

      result = described_class.new(user: user, year: 2025).call
      months = result[:per_day][:points].map { |point| point[:month] }

      expect(months).not_to include(2)
      expect(months).to include(1)
    end

    it 'includes per_km only for months with odometer delta' do
      vehicle = create(:vehicle, user: user)
      create(:earning, user: user, date: '2025-01-10', amount: 100.00)
      create(:earning, user: user, date: '2025-02-10', amount: 100.00)
      create(:earning, user: user, date: '2025-03-10', amount: 100.00)
      create(:refueling, vehicle: vehicle, date: '2025-01-05', odometer_km: 10_000)
      create(:refueling, vehicle: vehicle, date: '2025-01-20', odometer_km: 10_500)

      result = described_class.new(user: user, year: 2025).call

      expect(result[:per_km][:points].size).to eq(1)
      expect(result[:per_day][:points].size).to eq(3)
    end

    it 'picks the best month and keeps the first one on a tie' do
      create(:earning, user: user, date: '2025-01-10', amount: 100.00)
      create(:earning, user: user, date: '2025-02-10', amount: 300.00)
      create(:earning, user: user, date: '2025-03-10', amount: 300.00)

      result = described_class.new(user: user, year: 2025).call

      expect(result[:per_day][:best][:month]).to eq(2)
    end

    it 'returns empty points and nil best when there are no earnings' do
      result = described_class.new(user: user, year: 2025).call

      expect(result[:per_day][:points]).to eq([])
      expect(result[:per_day][:best]).to be_nil
    end

    it 'ignores other users records' do
      other_user = create(:user)
      create(:earning, user: other_user, date: '2025-01-10', amount: 100.00)

      result = described_class.new(user: user, year: 2025).call

      expect(result[:per_day][:points]).to eq([])
    end
  end
end
