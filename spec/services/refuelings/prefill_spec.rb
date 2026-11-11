require 'rails_helper'

RSpec.describe Refuelings::Prefill do
  let(:user) { create(:user) }
  let(:vehicle) { create(:vehicle, user: user, odometer_km: 160_928) }

  it 'prefills the vendor and odometer from the active tank' do
    create(:refueling, vehicle: vehicle, full_tank: true, vendor: 'Posto Orense', date: Date.current - 1)

    refueling = described_class.call(user: user)

    expect(refueling.vendor).to eq('Posto Orense')
    expect(refueling.odometer_km).to eq(160_928)
    expect(refueling).to be_full_tank
    expect(refueling).to be_new_record
  end

  it 'leaves the vendor blank when there is no previous refueling' do
    vehicle

    refueling = described_class.call(user: user)

    expect(refueling.vendor).to be_nil
  end
end
