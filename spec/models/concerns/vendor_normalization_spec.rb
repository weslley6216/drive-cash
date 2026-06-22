require 'rails_helper'

RSpec.describe VendorNormalization do
  let(:vehicle) { create(:vehicle) }

  it 'collapses inner whitespace on a refueling vendor' do
    refueling = build(:refueling, vehicle: vehicle, vendor: 'Posto   Orense')

    refueling.valid?

    expect(refueling.vendor).to eq('Posto Orense')
  end

  it 'trims surrounding whitespace on a refueling vendor' do
    refueling = build(:refueling, vehicle: vehicle, vendor: '  Geladão  ')

    refueling.valid?

    expect(refueling.vendor).to eq('Geladão')
  end

  it 'leaves nil vendor untouched' do
    refueling = build(:refueling, vehicle: vehicle, vendor: nil)

    refueling.valid?

    expect(refueling.vendor).to be_nil
  end

  it 'leaves an empty string as empty string' do
    refueling = build(:refueling, vehicle: vehicle, vendor: '   ')

    refueling.valid?

    expect(refueling.vendor).to eq('')
  end

  it 'normalizes an expense vendor on validation' do
    expense = build(:expense, vendor: ' Posto  Shell ')

    expense.valid?

    expect(expense.vendor).to eq('Posto Shell')
  end
end
