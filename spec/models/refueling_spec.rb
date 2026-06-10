require 'rails_helper'

RSpec.describe Refueling, type: :model do
  describe 'validations' do
    subject { build(:refueling) }

    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_presence_of(:liters) }
    it { is_expected.to validate_presence_of(:total_amount) }
    it { is_expected.to validate_presence_of(:odometer_km) }

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

  describe '#km_per_liter_to_previous' do
    it 'returns km/L using previous full_tank refueling' do
      vehicle = create(:vehicle)
      create(:refueling, vehicle: vehicle, date: Date.new(2026, 5, 1), odometer_km: 47_000, liters: 30, full_tank: true)
      current = create(:refueling, vehicle: vehicle, date: Date.new(2026, 6, 1), odometer_km: 47_330, liters: 30, full_tank: true)

      expect(current.km_per_liter_to_previous).to eq(11.0)
    end

    it 'returns nil when there is no previous full_tank refueling' do
      vehicle = create(:vehicle)
      refueling = create(:refueling, vehicle: vehicle, date: Date.new(2026, 6, 1), full_tank: true)

      expect(refueling.km_per_liter_to_previous).to be_nil
    end

    it 'returns nil when current refueling is not full_tank' do
      vehicle = create(:vehicle)
      create(:refueling, vehicle: vehicle, date: Date.new(2026, 5, 1), full_tank: true)
      current = create(:refueling, vehicle: vehicle, date: Date.new(2026, 6, 1), full_tank: false)

      expect(current.km_per_liter_to_previous).to be_nil
    end
  end
end
