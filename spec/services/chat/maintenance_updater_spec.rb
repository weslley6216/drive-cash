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

      result = described_class.new.persist({ 'category' => 'oil_change', 'done_km' => 40_000 }, user: user)

      expect(result.success?).to be false
      expect(result.errors).to be_present
    end

    it 'rejects done_km below the last recorded km' do
      user = create(:user)
      vehicle = create(:vehicle, user: user, odometer_km: 50_000)
      create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 45_000)

      result = described_class.new.persist({ 'category' => 'oil_change', 'done_km' => 40_000 }, user: user)

      expect(result.errors.join).to include(I18n.t('maintenances.mark_done.errors.below_last', km: '45.000'))
    end

    it 'syncs the odometer when done_km is ahead' do
      user = create(:user)
      vehicle = create(:vehicle, user: user, odometer_km: 50_000)
      create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 45_000)

      described_class.new.persist({ 'category' => 'oil_change', 'done_km' => 51_000 }, user: user)

      expect(vehicle.reload.odometer_km).to eq(51_000)
    end

    it 'does not touch companions' do
      user = create(:user)
      vehicle = create(:vehicle, user: user, odometer_km: 50_000)
      create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 45_000)
      oil_filter = create(:maintenance, vehicle: vehicle, category: 'oil_filter', last_done_km: 44_000)

      described_class.new.persist({ 'category' => 'oil_change', 'done_km' => 50_000 }, user: user)

      expect(oil_filter.reload.last_done_km).to eq(44_000)
    end
  end
end
