require 'rails_helper'

RSpec.describe Vehicles::OdometerSync do
  let(:vehicle) { create(:vehicle, odometer_km: 160_928, odometer_updated_at: Time.zone.local(2026, 6, 1, 10)) }

  it 'advances odometer_km and sets odometer_updated_at when reading is greater' do
    described_class.new(vehicle: vehicle, reading_km: 161_450, on: Date.new(2026, 6, 22)).call

    expect(vehicle.reload.odometer_km).to eq(161_450)
    expect(vehicle.odometer_updated_at.to_date).to eq(Date.new(2026, 6, 22))
  end

  it 'does nothing when reading equals current odometer' do
    described_class.new(vehicle: vehicle, reading_km: 160_928, on: Date.new(2026, 6, 22)).call

    expect(vehicle.reload.odometer_km).to eq(160_928)
    expect(vehicle.odometer_updated_at.to_date).to eq(Date.new(2026, 6, 1))
  end

  it 'does nothing when reading is smaller than current odometer' do
    described_class.new(vehicle: vehicle, reading_km: 159_000, on: Date.new(2026, 6, 22)).call

    expect(vehicle.reload.odometer_km).to eq(160_928)
    expect(vehicle.odometer_updated_at.to_date).to eq(Date.new(2026, 6, 1))
  end

  it 'does nothing when reading is nil' do
    described_class.new(vehicle: vehicle, reading_km: nil, on: Date.new(2026, 6, 22)).call

    expect(vehicle.reload.odometer_km).to eq(160_928)
  end

  it 'returns the vehicle' do
    result = described_class.new(vehicle: vehicle, reading_km: 161_450, on: Date.new(2026, 6, 22)).call

    expect(result).to eq(vehicle)
  end
end
