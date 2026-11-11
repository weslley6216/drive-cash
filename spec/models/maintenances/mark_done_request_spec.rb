require 'rails_helper'

RSpec.describe Maintenances::MarkDoneRequest do
  describe 'defaults' do
    it 'defaults done_km to the vehicle odometer' do
      vehicle = create(:vehicle, odometer_km: 160_928)
      maintenance = create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 155_600)

      request = described_class.new(maintenance: maintenance)

      expect(request.done_km).to eq(160_928)
    end

    it 'defaults done_on to today' do
      travel_to Time.zone.local(2026, 11, 10, 10, 0) do
        maintenance = create(:maintenance)

        request = described_class.new(maintenance: maintenance)

        expect(request.done_on).to eq(Date.new(2026, 11, 10))
      end
    end

    it 'preselects the first companion' do
      vehicle = create(:vehicle, odometer_km: 160_928)
      oil_change = create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 155_600)
      oil_filter = create(:maintenance, vehicle: vehicle, category: 'oil_filter', last_done_km: 150_800)

      request = described_class.new(maintenance: oil_change)

      expect(request.companion_ids).to eq([oil_filter.id])
    end
  end

  describe '#valid?' do
    it 'is valid at the last km of the item' do
      vehicle = create(:vehicle, odometer_km: 160_928)
      maintenance = create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 155_600)

      request = described_class.new(maintenance: maintenance, done_km: 155_600, companion_ids: [])

      expect(request).to be_valid
    end

    it 'is invalid below the last km' do
      vehicle = create(:vehicle, odometer_km: 160_928)
      maintenance = create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 155_600)

      request = described_class.new(maintenance: maintenance, done_km: 154_900, companion_ids: [])
      request.valid?

      expect(request.errors[:done_km]).to include(I18n.t('maintenances.mark_done.errors.below_last', km: '155.600'))
    end

    it 'cites the companion when done_km is below its last km' do
      vehicle = create(:vehicle, odometer_km: 160_928)
      oil_change = create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 100_000)
      oil_filter = create(:maintenance, vehicle: vehicle, category: 'oil_filter', last_done_km: 159_000)

      request = described_class.new(maintenance: oil_change, done_km: 158_000, companion_ids: [oil_filter.id])
      request.valid?

      expect(request.errors[:done_km]).to include(a_string_including('Filtro de óleo'))
    end

    it 'is invalid above odometer plus margin' do
      vehicle = create(:vehicle, odometer_km: 160_928)
      maintenance = create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 155_600)

      request = described_class.new(maintenance: maintenance, done_km: 162_929, companion_ids: [])

      expect(request).not_to be_valid
    end

    it 'is invalid with blank done_km' do
      maintenance = create(:maintenance)

      request = described_class.new(maintenance: maintenance, done_km: '', companion_ids: [])

      expect(request).not_to be_valid
    end
  end

  describe '#companions' do
    it 'ignores companion ids outside the registry or the vehicle' do
      vehicle = create(:vehicle, odometer_km: 160_928)
      oil_change = create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 155_600)
      oil_filter = create(:maintenance, vehicle: vehicle, category: 'oil_filter', last_done_km: 150_800)
      tire_rotation = create(:maintenance, vehicle: vehicle, category: 'tire_rotation', last_done_km: 150_000)
      foreign = create(:maintenance, category: 'oil_filter')

      request = described_class.new(maintenance: oil_change, companion_ids: [oil_filter.id, tire_rotation.id, foreign.id])

      expect(request.companions).to eq([oil_filter])
    end
  end
end
