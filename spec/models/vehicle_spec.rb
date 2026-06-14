require 'rails_helper'

RSpec.describe Vehicle, type: :model do
  describe 'validations' do
    subject { build(:vehicle) }

    it { is_expected.to validate_presence_of(:brand) }
    it { is_expected.to validate_presence_of(:vehicle_model) }
    it { is_expected.to validate_presence_of(:year) }
    it { is_expected.to validate_presence_of(:odometer_km) }

    it 'rejects negative odometer_km' do
      vehicle = build(:vehicle, odometer_km: -1)

      vehicle.valid?

      expect(vehicle.errors[:odometer_km]).to be_present
    end

    it 'rejects year before 1900' do
      vehicle = build(:vehicle, year: 1899)

      vehicle.valid?

      expect(vehicle.errors[:year]).to be_present
    end

    it 'rejects year in the far future' do
      vehicle = build(:vehicle, year: Date.current.year + 2)

      vehicle.valid?

      expect(vehicle.errors[:year]).to be_present
    end
  end

  describe 'associations' do
    it 'belongs to a user' do
      user = create(:user)
      vehicle = create(:vehicle, user: user)

      expect(vehicle.user).to eq(user)
    end

    it 'destroys dependent maintenances' do
      vehicle = create(:vehicle)
      create(:maintenance, vehicle: vehicle)

      expect { vehicle.destroy }.to change(Maintenance, :count).by(-1)
    end

    it 'destroys dependent refuelings' do
      vehicle = create(:vehicle)
      create(:refueling, vehicle: vehicle)

      expect { vehicle.destroy }.to change(Refueling, :count).by(-1)
    end
  end

  describe '#updated_days_ago' do
    it 'returns days since odometer was updated' do
      vehicle = build(:vehicle, odometer_updated_at: 3.days.ago)

      expect(vehicle.updated_days_ago).to eq(3)
    end

    it 'returns nil when never updated' do
      vehicle = build(:vehicle, odometer_updated_at: nil)

      expect(vehicle.updated_days_ago).to be_nil
    end
  end
end
