require 'rails_helper'

RSpec.describe Vehicles::Statistics do
  let(:user) { create(:user) }
  let(:vehicle) { create(:vehicle, user: user, odometer_km: 48_230) }
  let(:reference_date) { Date.new(2026, 6, 15) }

  describe '#km_this_month' do
    it 'returns delta between current odometer and first refueling of the month' do
      create(:refueling, vehicle: vehicle, date: Date.new(2026, 6, 1), odometer_km: 46_390)

      result = described_class.new(vehicle: vehicle, date: reference_date).km_this_month

      expect(result).to eq(1840)
    end

    it 'returns 0 when there is no refueling this month' do
      result = described_class.new(vehicle: vehicle, date: reference_date).km_this_month

      expect(result).to eq(0)
    end
  end
end
