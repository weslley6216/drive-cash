require 'rails_helper'

RSpec.describe Refuelings::RecentVendors do
  let(:user) { create(:user) }
  let(:vehicle) { create(:vehicle, user: user) }

  describe '.call' do
    it 'returns distinct vendors, most recent refueling first' do
      create(:refueling, vehicle: vehicle, vendor: 'Posto Orense', date: Date.new(2026, 6, 1))
      create(:refueling, vehicle: vehicle, vendor: 'Geladão', date: Date.new(2026, 6, 10))
      create(:refueling, vehicle: vehicle, vendor: 'Posto Orense', date: Date.new(2026, 6, 15))

      expect(described_class.call(vehicle: vehicle)).to eq(['Posto Orense', 'Geladão'])
    end

    it 'limits the result to the 4 most recent distinct vendors' do
      %w[A B C D E].each_with_index do |vendor, offset|
        create(:refueling, vehicle: vehicle, vendor: vendor, date: Date.new(2026, 6, 1 + offset))
      end

      expect(described_class.call(vehicle: vehicle)).to eq(%w[E D C B])
    end

    it 'returns an empty array when the vehicle has no refuelings' do
      expect(described_class.call(vehicle: vehicle)).to eq([])
    end
  end
end
