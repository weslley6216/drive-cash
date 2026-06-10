require 'rails_helper'

RSpec.describe Vehicles::Statistics do
  let(:user) { create(:user) }
  let(:vehicle) { create(:vehicle, user: user, odometer_km: 48_230) }
  let(:reference_date) { Date.new(2026, 6, 15) }

  describe '#km_this_month' do
    it 'returns delta between current odometer and first refueling of the month' do
      create(:refueling, vehicle: vehicle, date: Date.new(2026, 6, 1), odometer_km: 46_390)

      result = described_class.new(vehicle: vehicle, date: reference_date).km_this_month

      expect(result).to eq(1840)
    end

    it 'returns 0 when there is no refueling this month' do
      result = described_class.new(vehicle: vehicle, date: reference_date).km_this_month

      expect(result).to eq(0)
    end
  end

  describe '#cost_per_km' do
    it 'divides vehicle-related expenses by km rodados in the last 90 days' do
      create(:refueling, vehicle: vehicle, date: reference_date - 89.days, odometer_km: 47_230)
      create(:expense, user: user, category: 'fuel', amount: 270, date: reference_date - 30.days)

      result = described_class.new(vehicle: vehicle, date: reference_date).cost_per_km

      expect(result).to be_within(0.01).of(0.27)
    end

    it 'returns 0 when no km were tracked in the period' do
      result = described_class.new(vehicle: vehicle, date: reference_date).cost_per_km

      expect(result).to eq(0)
    end
  end

  describe '#revenue_per_km' do
    it 'divides earnings by km rodados in the last 90 days' do
      create(:refueling, vehicle: vehicle, date: reference_date - 89.days, odometer_km: 47_230)
      create(:earning, user: user, amount: 610, date: reference_date - 10.days)

      result = described_class.new(vehicle: vehicle, date: reference_date).revenue_per_km

      expect(result).to be_within(0.01).of(0.61)
    end
  end

  describe '#profit_per_km' do
    it 'returns revenue_per_km minus cost_per_km' do
      create(:refueling, vehicle: vehicle, date: reference_date - 89.days, odometer_km: 47_230)
      create(:earning, user: user, amount: 610, date: reference_date - 10.days)
      create(:expense, user: user, category: 'fuel', amount: 270, date: reference_date - 30.days)

      stats = described_class.new(vehicle: vehicle, date: reference_date)

      expect(stats.profit_per_km).to be_within(0.01).of(0.34)
    end
  end

  describe '#avg_km_per_liter' do
    it 'returns nil when there are fewer than 2 full_tank refuelings' do
      create(:refueling, vehicle: vehicle, full_tank: true, date: reference_date)

      result = described_class.new(vehicle: vehicle, date: reference_date).avg_km_per_liter

      expect(result).to be_nil
    end

    it 'averages km/L from consecutive full_tank refuelings' do
      create(:refueling, vehicle: vehicle, date: reference_date - 30.days, odometer_km: 47_000, liters: 30, full_tank: true)
      create(:refueling, vehicle: vehicle, date: reference_date - 15.days, odometer_km: 47_330, liters: 30, full_tank: true)
      create(:refueling, vehicle: vehicle, date: reference_date,           odometer_km: 47_690, liters: 30, full_tank: true)

      result = described_class.new(vehicle: vehicle, date: reference_date).avg_km_per_liter

      expect(result).to be_within(0.05).of(11.5)
    end

    it 'ignores partial (non full_tank) refuelings when averaging' do
      create(:refueling, vehicle: vehicle, date: reference_date - 30.days, odometer_km: 47_000, liters: 30, full_tank: true)
      create(:refueling, vehicle: vehicle, date: reference_date - 20.days, odometer_km: 47_100, liters: 10, full_tank: false)
      create(:refueling, vehicle: vehicle, date: reference_date,           odometer_km: 47_330, liters: 30, full_tank: true)

      result = described_class.new(vehicle: vehicle, date: reference_date).avg_km_per_liter

      expect(result).to be_within(0.05).of(11.0)
    end
  end
end
