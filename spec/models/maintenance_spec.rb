require 'rails_helper'

RSpec.describe Maintenance, type: :model do
  describe 'validations' do
    subject { build(:maintenance) }

    it { is_expected.to validate_presence_of(:name) }

    it 'allows estimated_cost to be blank' do
      maintenance = build(:maintenance, estimated_cost: nil)

      expect(maintenance).to be_valid
    end

    it 'rejects negative estimated_cost' do
      maintenance = build(:maintenance, estimated_cost: -1)

      maintenance.valid?

      expect(maintenance.errors[:estimated_cost]).to be_present
    end
  end

  describe 'enums' do
    it 'defines category enum' do
      expect(described_class.categories).to eq(
        'oil_change' => 0,
        'brake' => 1,
        'alignment' => 2,
        'tires' => 3,
        'other' => 4
      )
    end
  end

  describe 'scopes' do
    let(:vehicle) { create(:vehicle, odometer_km: 48_000) }

    describe '.pending' do
      it 'returns only non-completed maintenances' do
        pending_one = create(:maintenance, vehicle: vehicle, completed: false)
        create(:maintenance, vehicle: vehicle, completed: true)

        expect(described_class.pending).to contain_exactly(pending_one)
      end
    end

    describe '.due_soon' do
      it 'returns maintenances within km_threshold' do
        within = create(:maintenance, vehicle: vehicle, due_at_km: 48_500, due_at_date: nil)
        create(:maintenance, vehicle: vehicle, due_at_km: 60_000, due_at_date: nil)

        result = described_class.due_soon(odometer_km: vehicle.odometer_km, today: Date.current,
                                          km_threshold: 1000, day_threshold: 14)

        expect(result).to contain_exactly(within)
      end

      it 'returns maintenances within day_threshold' do
        within = create(:maintenance, vehicle: vehicle, due_at_km: nil, due_at_date: Date.current + 5.days)
        create(:maintenance, vehicle: vehicle, due_at_km: nil, due_at_date: Date.current + 90.days)

        result = described_class.due_soon(odometer_km: vehicle.odometer_km, today: Date.current,
                                          km_threshold: 1000, day_threshold: 14)

        expect(result).to contain_exactly(within)
      end
    end
  end

  describe '#urgent?' do
    let(:vehicle) { create(:vehicle, odometer_km: 48_000) }

    it 'is urgent when km_until is under km_threshold' do
      maintenance = build(:maintenance, vehicle: vehicle, due_at_km: 48_500, due_at_date: nil)

      expect(maintenance.urgent?(km_threshold: 1000, day_threshold: 14)).to be(true)
    end

    it 'is urgent when days_until is under day_threshold' do
      maintenance = build(:maintenance, vehicle: vehicle, due_at_km: nil, due_at_date: Date.current + 7.days)

      expect(maintenance.urgent?(km_threshold: 1000, day_threshold: 14)).to be(true)
    end

    it 'is not urgent when both thresholds are exceeded' do
      maintenance = build(:maintenance, vehicle: vehicle, due_at_km: 60_000, due_at_date: Date.current + 90.days)

      expect(maintenance.urgent?(km_threshold: 1000, day_threshold: 14)).to be(false)
    end

    it 'is not urgent when nothing was scheduled (both nil)' do
      maintenance = build(:maintenance, vehicle: vehicle, due_at_km: nil, due_at_date: nil)

      expect(maintenance.urgent?(km_threshold: 1000, day_threshold: 14)).to be(false)
    end
  end

  describe '#km_until' do
    it 'returns difference between due_at_km and vehicle odometer' do
      vehicle = create(:vehicle, odometer_km: 48_000)
      maintenance = build(:maintenance, vehicle: vehicle, due_at_km: 49_500)

      expect(maintenance.km_until).to eq(1500)
    end

    it 'returns nil when due_at_km is blank' do
      maintenance = build(:maintenance, due_at_km: nil)

      expect(maintenance.km_until).to be_nil
    end
  end

  describe '#days_until' do
    it 'returns difference in days from today to due_at_date' do
      maintenance = build(:maintenance, due_at_date: Date.current + 10.days)

      expect(maintenance.days_until(today: Date.current)).to eq(10)
    end

    it 'returns nil when due_at_date is blank' do
      maintenance = build(:maintenance, due_at_date: nil)

      expect(maintenance.days_until(today: Date.current)).to be_nil
    end
  end
end
