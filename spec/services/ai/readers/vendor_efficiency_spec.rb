require 'rails_helper'

RSpec.describe Ai::Readers::VendorEfficiency do
  describe '#call' do
    it 'returns nil when user has no vehicle' do
      user = create(:user)

      result = described_class.new({}, user: user).call

      expect(result).to be_nil
    end

    it 'returns nil when not enough data for comparison' do
      user = create(:user)
      create(:vehicle, user: user)

      result = described_class.new({}, user: user).call

      expect(result).to be_nil
    end

    it 'returns Comparison when vehicle has enough data' do
      user = create(:user)
      vehicle = create(:vehicle, user: user, odometer_km: 60_000)
      create(:refueling, vehicle: vehicle, vendor: 'Shell', odometer_km: 50_000, full_tank: true, liters: 40)
      create(:refueling, vehicle: vehicle, vendor: 'Shell', odometer_km: 55_000, full_tank: true, liters: 38)
      create(:refueling, vehicle: vehicle, vendor: 'Ipiranga', odometer_km: 52_000, full_tank: true, liters: 42)
      create(:refueling, vehicle: vehicle, vendor: 'Ipiranga', odometer_km: 57_000, full_tank: true, liters: 44)
      create(:refueling, vehicle: vehicle, vendor: 'Posto X', odometer_km: 53_000, full_tank: true, liters: 45)
      create(:refueling, vehicle: vehicle, vendor: 'Posto X', odometer_km: 58_000, full_tank: true, liters: 46)

      result = described_class.new({}, user: user).call

      expect(result).to respond_to(:winner)
      expect(result).to respond_to(:winner_kml)
    end

    it 'does not leak data from other users' do
      user = create(:user)
      other = create(:user)
      vehicle2 = create(:vehicle, user: other, odometer_km: 60_000)
      create(:refueling, vehicle: vehicle2, vendor: 'Shell', odometer_km: 50_000, full_tank: true, liters: 40)
      create(:refueling, vehicle: vehicle2, vendor: 'Shell', odometer_km: 55_000, full_tank: true, liters: 38)
      create(:refueling, vehicle: vehicle2, vendor: 'Ipiranga', odometer_km: 52_000, full_tank: true, liters: 42)
      create(:refueling, vehicle: vehicle2, vendor: 'Ipiranga', odometer_km: 57_000, full_tank: true, liters: 44)
      create(:refueling, vehicle: vehicle2, vendor: 'Posto X', odometer_km: 53_000, full_tank: true, liters: 45)
      create(:refueling, vehicle: vehicle2, vendor: 'Posto X', odometer_km: 58_000, full_tank: true, liters: 46)

      result = described_class.new({}, user: user).call

      expect(result).to be_nil
    end
  end
end
