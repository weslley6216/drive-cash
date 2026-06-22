require 'rails_helper'

RSpec.describe Refueling, type: :model do
  describe 'validations' do
    subject { build(:refueling) }

    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_presence_of(:total_amount) }

    it 'accepts nil liters for imported records' do
      refueling = build(:refueling, liters: nil)

      expect(refueling).to be_valid
    end

    it 'accepts nil odometer_km for imported records' do
      refueling = build(:refueling, odometer_km: nil)

      expect(refueling).to be_valid
    end

    it 'rejects liters equal to zero' do
      refueling = build(:refueling, liters: 0)

      refueling.valid?

      expect(refueling.errors[:liters]).to be_present
    end

    it 'rejects negative total_amount' do
      refueling = build(:refueling, total_amount: -1)

      refueling.valid?

      expect(refueling.errors[:total_amount]).to be_present
    end
  end

  describe 'associations' do
    it 'belongs to a vehicle' do
      vehicle = create(:vehicle)
      refueling = create(:refueling, vehicle: vehicle)

      expect(refueling.vehicle).to eq(vehicle)
    end

    it 'allows expense to be nil' do
      refueling = create(:refueling, expense: nil)

      expect(refueling).to be_valid
    end

    it 'links to an expense when provided' do
      expense = create(:expense, category: 'fuel')
      refueling = create(:refueling, expense: expense)

      expect(refueling.expense).to eq(expense)
    end
  end

  describe 'before_save price_per_liter' do
    it 'computes price_per_liter from total and liters' do
      refueling = create(:refueling, liters: 30.00, total_amount: 180.00)

      expect(refueling.price_per_liter).to eq(6.000)
    end

    it 'recomputes price_per_liter after update' do
      refueling = create(:refueling, liters: 30.00, total_amount: 180.00)

      refueling.update(liters: 20.00, total_amount: 140.00)

      expect(refueling.reload.price_per_liter).to eq(7.000)
    end
  end

  describe '.full_tank' do
    it 'returns only full tank refuelings' do
      full_tank = create(:refueling, full_tank: true)
      create(:refueling, full_tank: false)

      expect(described_class.full_tank).to contain_exactly(full_tank)
    end
  end

  describe '.chronological' do
    it 'orders by date desc then created_at desc' do
      vehicle = create(:vehicle)
      older = create(:refueling, vehicle: vehicle, date: Date.new(2026, 5, 1))
      newer = create(:refueling, vehicle: vehicle, date: Date.new(2026, 6, 1))

      expect(described_class.chronological).to eq([newer, older])
    end
  end

  describe 'odometer sync callback' do
    let(:vehicle) { create(:vehicle, odometer_km: 160_928, odometer_updated_at: Time.zone.local(2026, 6, 1, 10)) }

    it 'advances the vehicle odometer when the refueling km is greater' do
      create(:refueling, vehicle: vehicle, odometer_km: 161_450, date: Date.new(2026, 6, 22))

      expect(vehicle.reload.odometer_km).to eq(161_450)
      expect(vehicle.odometer_updated_at.to_date).to eq(Date.new(2026, 6, 22))
    end

    it 'does not recede the odometer for a retroactive refueling' do
      create(:refueling, vehicle: vehicle, odometer_km: 159_000, date: Date.new(2026, 5, 10))

      expect(vehicle.reload.odometer_km).to eq(160_928)
      expect(vehicle.odometer_updated_at.to_date).to eq(Date.new(2026, 6, 1))
    end

    it 'ignores refuelings without odometer_km' do
      create(:refueling, vehicle: vehicle, odometer_km: nil, date: Date.new(2026, 6, 22))

      expect(vehicle.reload.odometer_km).to eq(160_928)
    end

    it 'does not trigger when the odometer_km is unchanged on update' do
      refueling = create(:refueling, vehicle: vehicle, odometer_km: 161_450, date: Date.new(2026, 6, 22))
      vehicle.reload

      refueling.update!(total_amount: 250)

      expect(vehicle.reload.odometer_updated_at.to_date).to eq(Date.new(2026, 6, 22))
    end

    it 'advances again when the odometer_km is raised on update' do
      refueling = create(:refueling, vehicle: vehicle, odometer_km: 161_000, date: Date.new(2026, 6, 22))

      refueling.update!(odometer_km: 162_000)

      expect(vehicle.reload.odometer_km).to eq(162_000)
    end
  end
end
