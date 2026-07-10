require 'rails_helper'

RSpec.describe Maintenance, type: :model do
  describe '#progress' do
    it 'computes percentage of interval consumed since last done' do
      vehicle = create(:vehicle, odometer_km: 160_928)
      maintenance = build(:maintenance, vehicle: vehicle, last_done_km: 158_318, interval_km: 5_000)

      expect(maintenance.progress).to be_within(0.01).of(52.2)
    end
  end

  describe '#target and #km_until' do
    it 'returns remaining km to the target' do
      vehicle = create(:vehicle, odometer_km: 160_928)
      maintenance = build(:maintenance, vehicle: vehicle, last_done_km: 158_318, interval_km: 5_000)

      expect(maintenance.target).to eq(163_318)
      expect(maintenance.km_until).to eq(2_390)
    end

    it 'returns negative when overdue' do
      vehicle = create(:vehicle, odometer_km: 160_928)
      maintenance = build(:maintenance, vehicle: vehicle, last_done_km: 150_000, interval_km: 5_000)

      expect(maintenance.km_until).to eq(-5_928)
    end
  end

  describe '.catalog_defaults' do
    it 'returns interval and cost for a known kind' do
      defaults = described_class.catalog_defaults('timing_belt')

      expect(defaults[:interval_km]).to eq(60_000)
      expect(defaults[:estimated_cost]).to eq(900)
    end
  end

  describe '#apply_catalog_defaults' do
    it 'fills interval and cost from the catalog when blank' do
      vehicle = create(:vehicle)
      maintenance = vehicle.maintenances.new(category: 'timing_belt', last_done_km: 110_000)

      maintenance.apply_catalog_defaults

      expect(maintenance.interval_km).to eq(60_000)
      expect(maintenance.estimated_cost).to eq(900)
    end

    it 'keeps provided values over the catalog defaults' do
      vehicle = create(:vehicle)
      maintenance = vehicle.maintenances.new(category: 'timing_belt', last_done_km: 110_000, interval_km: 5_000, estimated_cost: 100)

      maintenance.apply_catalog_defaults

      expect(maintenance.interval_km).to eq(5_000)
      expect(maintenance.estimated_cost).to eq(100)
    end

    it 'returns self so it can be chained after new' do
      maintenance = build(:maintenance)

      expect(maintenance.apply_catalog_defaults).to be(maintenance)
    end
  end

  describe '#selectable_categories' do
    it 'excludes categories already used on the vehicle for a new record' do
      vehicle = create(:vehicle)
      create(:maintenance, vehicle: vehicle, category: 'oil_change')
      new_maintenance = vehicle.maintenances.new

      expect(new_maintenance.selectable_categories).not_to include('oil_change')
      expect(new_maintenance.selectable_categories).to include('air_filter')
    end

    it 'keeps its own category available for a persisted record' do
      vehicle = create(:vehicle)
      maintenance = create(:maintenance, vehicle: vehicle, category: 'oil_change')

      expect(maintenance.selectable_categories).to include('oil_change')
    end
  end

  describe 'enums' do
    it 'defines the eight catalog categories' do
      expect(described_class.categories.keys).to eq(described_class::CATALOG.keys)
    end
  end

  describe 'validations' do
    it 'requires last_done_km and interval_km' do
      maintenance = described_class.new

      expect(maintenance).not_to be_valid
      expect(maintenance.errors.attribute_names).to include(:last_done_km, :interval_km)
    end

    it 'allows estimated_cost to be blank' do
      maintenance = build(:maintenance, estimated_cost: nil)

      expect(maintenance).to be_valid
    end

    it 'rejects negative estimated_cost' do
      maintenance = build(:maintenance, estimated_cost: -1)

      maintenance.valid?

      expect(maintenance.errors[:estimated_cost]).to be_present
    end

    it 'enforces one maintenance per category and vehicle' do
      vehicle = create(:vehicle)
      create(:maintenance, vehicle: vehicle, category: 'oil_change')
      duplicate = build(:maintenance, vehicle: vehicle, category: 'oil_change')

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:category]).to be_present
    end

    it 'allows the same category on different vehicles' do
      create(:maintenance, vehicle: create(:vehicle), category: 'oil_change')
      other = build(:maintenance, vehicle: create(:vehicle), category: 'oil_change')

      expect(other).to be_valid
    end
  end
end
