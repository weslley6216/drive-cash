require 'rails_helper'

RSpec.describe Vehicles::TankCadence do
  let(:user) { create(:user) }
  let(:vehicle) { create(:vehicle, user: user) }

  it 'returns the average gap in days between consecutive full_tank refuelings' do
    create(:refueling, vehicle: vehicle, full_tank: true, date: Date.new(2026, 5, 1))
    create(:refueling, vehicle: vehicle, full_tank: true, date: Date.new(2026, 5, 11))
    create(:refueling, vehicle: vehicle, full_tank: true, date: Date.new(2026, 5, 21))

    result = described_class.new(user: user).call

    expect(result[:average_days]).to eq(10)
  end

  it 'ignores partial refuelings when computing the average' do
    create(:refueling, vehicle: vehicle, full_tank: true, date: Date.new(2026, 5, 1))
    create(:refueling, vehicle: vehicle, full_tank: false, date: Date.new(2026, 5, 5))
    create(:refueling, vehicle: vehicle, full_tank: true, date: Date.new(2026, 5, 11))

    result = described_class.new(user: user).call

    expect(result[:average_days]).to eq(10)
  end

  it 'returns nil when there is less than two full_tank refuelings' do
    create(:refueling, vehicle: vehicle, full_tank: true, date: Date.new(2026, 5, 1))

    result = described_class.new(user: user).call

    expect(result[:average_days]).to be_nil
  end

  it 'returns nil without a vehicle' do
    user_without_vehicle = create(:user)

    result = described_class.new(user: user_without_vehicle).call

    expect(result[:average_days]).to be_nil
  end
end
