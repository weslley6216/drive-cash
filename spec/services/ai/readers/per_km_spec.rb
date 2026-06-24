require 'rails_helper'

RSpec.describe Ai::Readers::PerKm do
  describe '#call' do
    it 'returns per km value when earnings and km data exist' do
      user = create(:user)
      vehicle = create(:vehicle, user: user)
      create(:earning, user: user, amount: 1000, date: Date.new(2026, 6, 10))
      create(:refueling, vehicle: vehicle, odometer_km: 50_000, date: Date.new(2026, 6, 1))
      create(:refueling, vehicle: vehicle, odometer_km: 51_000, date: Date.new(2026, 6, 30))

      result = described_class.new({ 'year' => 2026, 'month' => 6 }, user: user).call

      expect(result).to be_present
    end

    it 'returns nil when no km data' do
      user = create(:user)
      create(:earning, user: user, amount: 1000, date: Date.new(2026, 6, 10))

      result = described_class.new({ 'year' => 2026, 'month' => 6 }, user: user).call

      expect(result).to be_nil
    end

    it 'does not include records from other users' do
      user = create(:user)
      other = create(:user)
      vehicle = create(:vehicle, user: other)
      create(:earning, user: other, amount: 1000, date: Date.new(2026, 6, 10))
      create(:refueling, vehicle: vehicle, odometer_km: 50_000, date: Date.new(2026, 6, 1))
      create(:refueling, vehicle: vehicle, odometer_km: 51_000, date: Date.new(2026, 6, 30))

      result = described_class.new({ 'year' => 2026, 'month' => 6 }, user: user).call

      expect(result).to be_nil
    end
  end
end
