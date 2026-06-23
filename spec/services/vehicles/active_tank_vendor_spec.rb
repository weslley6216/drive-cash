require 'rails_helper'

RSpec.describe Vehicles::ActiveTankVendor do
  let(:user) { create(:user) }
  let(:vehicle) { create(:vehicle, user: user) }

  it 'returns the vendor of the most recent full_tank refueling' do
    create(:refueling, vehicle: vehicle, vendor: 'Posto Geladão', full_tank: true, date: Date.new(2026, 6, 1))
    create(:refueling, vehicle: vehicle, vendor: 'Posto Orense', full_tank: true, date: Date.new(2026, 6, 20))

    result = described_class.new(user: user).call

    expect(result).to eq('Posto Orense')
  end

  it 'ignores partial refuelings' do
    create(:refueling, vehicle: vehicle, vendor: 'Posto Orense', full_tank: true, date: Date.new(2026, 6, 1))
    create(:refueling, vehicle: vehicle, vendor: 'Posto Shell', full_tank: false, date: Date.new(2026, 6, 20))

    result = described_class.new(user: user).call

    expect(result).to eq('Posto Orense')
  end

  it 'returns nil when the user has no vehicle' do
    user_without_vehicle = create(:user)

    result = described_class.new(user: user_without_vehicle).call

    expect(result).to be_nil
  end

  it 'returns nil when there are no full_tank refuelings' do
    create(:refueling, vehicle: vehicle, vendor: 'Posto Orense', full_tank: false, date: Date.new(2026, 6, 1))

    result = described_class.new(user: user).call

    expect(result).to be_nil
  end

  it 'returns the vendor normalized by VendorNormalization' do
    create(:refueling, vehicle: vehicle, vendor: '  Posto   Orense ', full_tank: true, date: Date.new(2026, 6, 20))

    result = described_class.new(user: user).call

    expect(result).to eq('Posto Orense')
  end

  it 'normalizes unicode whitespace not covered by VendorNormalization' do
    refueling = create(:refueling, vehicle: vehicle, vendor: 'Posto Ipiranga', full_tank: true, date: Date.new(2026, 6, 20))
    refueling.update_column(:vendor, "Posto Ipiranga")

    result = described_class.new(user: user).call

    expect(result).to eq('Posto Ipiranga')
  end
end
