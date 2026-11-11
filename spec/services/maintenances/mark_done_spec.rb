require 'rails_helper'

RSpec.describe Maintenances::MarkDone do
  describe '.call' do
    it 'stores the informed done_km, not the odometer' do
      user = create(:user)
      vehicle = create(:vehicle, user: user, odometer_km: 160_928)
      maintenance = create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 155_600)
      request = Maintenances::MarkDoneRequest.new(maintenance: maintenance, done_km: 159_000, companion_ids: [])

      described_class.call(request: request)

      expect(maintenance.reload.last_done_km).to eq(159_000)
      expect(vehicle.reload.odometer_km).to eq(160_928)
    end

    it 'updates selected companions and leaves unselected ones' do
      user = create(:user)
      vehicle = create(:vehicle, user: user, odometer_km: 160_928)
      oil_change = create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 155_600)
      oil_filter = create(:maintenance, vehicle: vehicle, category: 'oil_filter', last_done_km: 150_800)
      air_filter = create(:maintenance, vehicle: vehicle, category: 'air_filter', last_done_km: 148_000)
      request = Maintenances::MarkDoneRequest.new(maintenance: oil_change, done_km: 160_928, companion_ids: [oil_filter.id])

      described_class.call(request: request)

      expect(oil_filter.reload.last_done_km).to eq(160_928)
      expect(air_filter.reload.last_done_km).to eq(148_000)
    end

    it 'syncs the odometer when done_km is ahead' do
      user = create(:user)
      vehicle = create(:vehicle, user: user, odometer_km: 160_928)
      maintenance = create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 155_600)
      request = Maintenances::MarkDoneRequest.new(maintenance: maintenance, done_km: 161_150, done_on: Date.new(2026, 11, 9), companion_ids: [])

      described_class.call(request: request)

      expect(vehicle.reload.odometer_km).to eq(161_150)
      expect(vehicle.odometer_updated_at.to_date).to eq(Date.new(2026, 11, 9))
    end

    it 'marks unread maintenance_due notifications of updated items as read' do
      user = create(:user)
      vehicle = create(:vehicle, user: user, odometer_km: 160_928)
      maintenance = create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 155_600)
      notification = create(:notification, user: user, kind: 'maintenance_due', data: { 'maintenance_id' => maintenance.id.to_s })
      request = Maintenances::MarkDoneRequest.new(maintenance: maintenance, done_km: 160_928, companion_ids: [])

      described_class.call(request: request)

      expect(notification.reload.unread?).to be false
    end

    it 'keeps notifications of other maintenances unread' do
      user = create(:user)
      vehicle = create(:vehicle, user: user, odometer_km: 160_928)
      maintenance = create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 155_600)
      other = create(:maintenance, vehicle: vehicle, category: 'tire_rotation', last_done_km: 150_000)
      other_notification = create(:notification, user: user, kind: 'maintenance_due', data: { 'maintenance_id' => other.id.to_s })
      request = Maintenances::MarkDoneRequest.new(maintenance: maintenance, done_km: 160_928, companion_ids: [])

      described_class.call(request: request)

      expect(other_notification.reload.unread?).to be true
    end

    it 'returns previous km per target' do
      user = create(:user)
      vehicle = create(:vehicle, user: user, odometer_km: 160_928)
      oil = create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 155_600)
      filter = create(:maintenance, vehicle: vehicle, category: 'oil_filter', last_done_km: 150_800)
      request = Maintenances::MarkDoneRequest.new(maintenance: oil, done_km: 160_928, companion_ids: [filter.id])

      result = described_class.call(request: request)

      expect(result.previous_km).to eq({ oil.id.to_s => 155_600, filter.id.to_s => 150_800 })
    end

    it 'returns failure and persists nothing when the request is invalid' do
      vehicle = create(:vehicle, odometer_km: 160_928)
      maintenance = create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 155_600)
      request = Maintenances::MarkDoneRequest.new(maintenance: maintenance, done_km: 100_000, companion_ids: [])

      result = described_class.call(request: request)

      expect(result.success?).to be false
      expect(result.previous_km).to eq({})
      expect(maintenance.reload.last_done_km).to eq(155_600)
    end
  end
end
