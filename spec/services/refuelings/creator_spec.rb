require 'rails_helper'

RSpec.describe Refuelings::Creator do
  let(:user) { create(:user) }
  let(:vehicle) { create(:vehicle, user: user, odometer_km: 48_000, odometer_updated_at: Time.zone.local(2026, 6, 1)) }

  describe '.call' do
    it 'creates the refueling and returns success' do
      result = described_class.call(
        vehicle: vehicle,
        params:  { date: Date.new(2026, 6, 22), vendor: 'Posto', liters: '30', total_amount: '180', odometer_km: '48230', full_tank: true }
      )

      expect(result.success?).to be(true)
      expect(result.refueling).to be_persisted
      expect(vehicle.refuelings.count).to eq(1)
    end

    it 'advances the vehicle odometer within the same transaction' do
      described_class.call(
        vehicle: vehicle,
        params:  { date: Date.new(2026, 6, 22), total_amount: '180', odometer_km: '48230' }
      )

      expect(vehicle.reload.odometer_km).to eq(48_230)
      expect(vehicle.odometer_updated_at.to_date).to eq(Date.new(2026, 6, 22))
    end

    it 'returns failure and persists nothing when the refueling is invalid' do
      result = described_class.call(
        vehicle: vehicle,
        params:  { date: Date.new(2026, 6, 22), total_amount: '180', odometer_km: '48230', liters: '0' }
      )

      expect(result.success?).to be(false)
      expect(result.refueling.errors[:liters]).to be_present
      expect(vehicle.refuelings.count).to eq(0)
      expect(vehicle.reload.odometer_km).to eq(48_000)
    end
  end
end
