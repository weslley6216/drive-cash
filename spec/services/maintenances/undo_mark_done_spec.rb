require 'rails_helper'

RSpec.describe Maintenances::UndoMarkDone do
  describe '.call' do
    it 'restores previous km of each listed maintenance' do
      vehicle = create(:vehicle, odometer_km: 160_928)
      oil = create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 160_928)
      filter = create(:maintenance, vehicle: vehicle, category: 'oil_filter', last_done_km: 160_928)

      described_class.call(vehicle: vehicle, restore: { oil.id => 155_600, filter.id => 150_800 })

      expect(oil.reload.last_done_km).to eq(155_600)
      expect(filter.reload.last_done_km).to eq(150_800)
    end

    it 'does not change the odometer' do
      vehicle = create(:vehicle, odometer_km: 160_928)
      oil = create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 160_928)

      described_class.call(vehicle: vehicle, restore: { oil.id => 155_600 })

      expect(vehicle.reload.odometer_km).to eq(160_928)
    end

    it 'ignores maintenances of other vehicles' do
      vehicle = create(:vehicle, odometer_km: 160_928)
      oil = create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 160_928)
      foreign = create(:maintenance, last_done_km: 50_000)

      described_class.call(vehicle: vehicle, restore: { oil.id => 155_600, foreign.id => 1 })

      expect(foreign.reload.last_done_km).to eq(50_000)
    end

    it 'returns false and rolls back when a value is invalid' do
      vehicle = create(:vehicle, odometer_km: 160_928)
      oil = create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 160_928)
      filter = create(:maintenance, vehicle: vehicle, category: 'oil_filter', last_done_km: 160_928)

      result = described_class.call(vehicle: vehicle, restore: { oil.id => 0, filter.id => 150_800 })

      expect(result).to be false
      expect(oil.reload.last_done_km).to eq(160_928)
      expect(filter.reload.last_done_km).to eq(160_928)
    end
  end
end
