require 'rails_helper'

RSpec.describe Refuelings::Updater do
  let(:user) { create(:user) }
  let(:vehicle) { create(:vehicle, user: user, odometer_km: 48_000, odometer_updated_at: Time.zone.local(2026, 6, 1)) }
  let(:refueling) { create(:refueling, vehicle: vehicle, odometer_km: 48_000, date: Date.new(2026, 6, 10)) }

  describe '.call' do
    it 'updates the refueling and returns success' do
      result = described_class.call(refueling: refueling, params: { total_amount: '200' })

      expect(result.success?).to be(true)
      expect(refueling.reload.total_amount).to eq(200)
    end

    it 'advances the vehicle odometer when the updated km is higher' do
      described_class.call(refueling: refueling, params: { odometer_km: '48500', date: Date.new(2026, 6, 22) })

      expect(vehicle.reload.odometer_km).to eq(48_500)
    end

    it 'returns failure and keeps the odometer when the update is invalid' do
      result = described_class.call(refueling: refueling, params: { total_amount: '0' })

      expect(result.success?).to be(false)
      expect(result.refueling.errors[:total_amount]).to be_present
      expect(vehicle.reload.odometer_km).to eq(48_000)
    end
  end
end
