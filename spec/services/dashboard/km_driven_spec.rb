require 'rails_helper'

RSpec.describe Dashboard::KmDriven do
  let(:user) { create(:user) }
  let(:vehicle) { create(:vehicle, user: user) }

  describe '#call' do
    it 'returns the delta between max and min odometer readings in the period' do
      create(:refueling, vehicle: vehicle, date: Date.new(2025, 6, 1), odometer_km: 10_000)
      create(:refueling, vehicle: vehicle, date: Date.new(2025, 6, 15), odometer_km: 12_500)

      result = described_class.new(user: user, year: 2025, month: 6).call

      expect(result).to eq(2500)
    end

    it 'returns nil when there are fewer than two readings with odometer_km' do
      create(:refueling, vehicle: vehicle, date: Date.new(2025, 6, 1), odometer_km: 10_000)

      result = described_class.new(user: user, year: 2025, month: 6).call

      expect(result).to be_nil
    end

    it 'returns nil when the user has no vehicle' do
      no_vehicle_user = create(:user)

      result = described_class.new(user: no_vehicle_user, year: 2025, month: 6).call

      expect(result).to be_nil
    end

    it 'ignores refuelings without odometer_km' do
      create(:refueling, vehicle: vehicle, date: Date.new(2025, 6, 1), odometer_km: 10_000)
      create(:refueling, vehicle: vehicle, date: Date.new(2025, 6, 15), odometer_km: nil)

      result = described_class.new(user: user, year: 2025, month: 6).call

      expect(result).to be_nil
    end

    it 'covers the whole year when month is nil' do
      create(:refueling, vehicle: vehicle, date: Date.new(2025, 1, 1), odometer_km: 10_000)
      create(:refueling, vehicle: vehicle, date: Date.new(2025, 12, 1), odometer_km: 15_000)

      result = described_class.new(user: user, year: 2025).call

      expect(result).to eq(5000)
    end

    it 'ignores refuelings from other users' do
      other_vehicle = create(:vehicle)
      create(:refueling, vehicle: other_vehicle, date: Date.new(2025, 6, 1), odometer_km: 0)
      create(:refueling, vehicle: other_vehicle, date: Date.new(2025, 6, 15), odometer_km: 99_999)

      result = described_class.new(user: user, year: 2025, month: 6).call

      expect(result).to be_nil
    end

    it 'returns nil when delta is not positive' do
      create(:refueling, vehicle: vehicle, date: Date.new(2025, 6, 1), odometer_km: 10_000)
      create(:refueling, vehicle: vehicle, date: Date.new(2025, 6, 15), odometer_km: 10_000)

      result = described_class.new(user: user, year: 2025, month: 6).call

      expect(result).to be_nil
    end
  end
end
