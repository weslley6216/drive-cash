require 'rails_helper'

RSpec.describe Chat::MaintenanceUpdater do
  describe '#persist' do
    it 'updates last_done_km when category matches' do
      user = create(:user)
      vehicle = create(:vehicle, user: user, odometer_km: 50_000)
      create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 45_000)

      result = described_class.new.persist({ 'category' => 'oil_change', 'done_km' => 50_000 }, user: user)

      expect(result.success?).to be true
      expect(result.record.last_done_km).to eq(50_000)
    end

    it 'uses current odometer when done_km is absent' do
      user = create(:user)
      vehicle = create(:vehicle, user: user, odometer_km: 55_000)
      create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 45_000)

      result = described_class.new.persist({ 'category' => 'oil_change' }, user: user)

      expect(result.record.last_done_km).to eq(55_000)
    end

    it 'returns failure when user has no vehicle' do
      user = create(:user)

      result = described_class.new.persist({ 'category' => 'oil_change' }, user: user)

      expect(result.success?).to be false
    end

    it 'returns failure when maintenance category not found' do
      user = create(:user)
      vehicle = create(:vehicle, user: user)

      result = described_class.new.persist({ 'category' => 'oil_change' }, user: user)

      expect(result.success?).to be false
    end

    it 'returns failure when update violates validation' do
      user = create(:user)
      vehicle = create(:vehicle, user: user, odometer_km: 50_000)
      create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 45_000)

      result = described_class.new.persist({ 'category' => 'oil_change', 'done_km' => 0 }, user: user)

      expect(result.success?).to be false
      expect(result.errors).to be_present
    end
  end
end
