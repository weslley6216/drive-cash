require 'rails_helper'

RSpec.describe Refuelings::VendorEfficiency do
  let(:vehicle) { create(:vehicle, odometer_km: 160_928) }
  let(:reference_date) { Date.new(2026, 6, 15) }

  describe '#cheapest' do
    context 'with fewer than 3 distinct vendors' do
      it 'returns nil' do
        create(:refueling, vehicle: vehicle, vendor: 'Posto Orense', date: reference_date - 30.days, odometer_km: 159_000)
        create(:refueling, vehicle: vehicle, vendor: 'Posto Orense', date: reference_date, odometer_km: 159_330)

        result = described_class.new(vehicle: vehicle, date: reference_date).cheapest

        expect(result).to be_nil
      end
    end

    context 'when a vendor has a single reading' do
      it 'ignores that vendor when counting distinct averages' do
        create(:refueling, vehicle: vehicle, vendor: 'Posto Orense', date: reference_date - 60.days, odometer_km: 156_000, liters: 30, total_amount: 165)
        create(:refueling, vehicle: vehicle, vendor: 'Posto Orense', date: reference_date - 30.days, odometer_km: 156_345, liters: 30, total_amount: 165)
        create(:refueling, vehicle: vehicle, vendor: 'Posto Geladão', date: reference_date - 20.days, odometer_km: 156_675, liters: 28, total_amount: 168)
        create(:refueling, vehicle: vehicle, vendor: 'Posto Geladão', date: reference_date - 10.days, odometer_km: 156_983, liters: 28, total_amount: 168)
        create(:refueling, vehicle: vehicle, vendor: 'Posto Shell', date: reference_date, odometer_km: 157_300, liters: 30, total_amount: 175)

        result = described_class.new(vehicle: vehicle, date: reference_date).cheapest

        expect(result).to be_nil
      end
    end

    context 'with at least 3 vendors with paired readings' do
      before do
        create(:refueling, vehicle: vehicle, vendor: 'Posto Orense', date: reference_date - 60.days, odometer_km: 156_000, liters: 30, total_amount: 165)
        create(:refueling, vehicle: vehicle, vendor: 'Posto Orense', date: reference_date - 30.days, odometer_km: 156_345, liters: 30, total_amount: 165)
        create(:refueling, vehicle: vehicle, vendor: 'Posto Geladão', date: reference_date - 20.days, odometer_km: 156_675, liters: 28, total_amount: 168)
        create(:refueling, vehicle: vehicle, vendor: 'Posto Geladão', date: reference_date - 10.days, odometer_km: 156_983, liters: 28, total_amount: 168)
        create(:refueling, vehicle: vehicle, vendor: 'Posto Shell', date: reference_date - 5.days, odometer_km: 157_300, liters: 30, total_amount: 175)
        create(:refueling, vehicle: vehicle, vendor: 'Posto Shell', date: reference_date, odometer_km: 157_620, liters: 30, total_amount: 175)
      end

      it 'returns the most efficient vendor as winner' do
        result = described_class.new(vehicle: vehicle, date: reference_date).cheapest

        expect(result.winner).to eq('Posto Orense')
        expect(result.winner_kml).to be > result.runner_up_kml
      end

      it 'estimates positive monthly savings against the runner up' do
        result = described_class.new(vehicle: vehicle, date: reference_date).cheapest

        expect(result.savings).to be_positive
      end
    end

    context 'when some readings have nil odometer_km' do
      it 'skips them and still computes valid averages' do
        create(:refueling, vehicle: vehicle, vendor: 'Posto Orense', date: reference_date - 60.days, odometer_km: 156_000, liters: 30, total_amount: 165)
        create(:refueling, vehicle: vehicle, vendor: 'Posto Orense', date: reference_date - 30.days, odometer_km: 156_345, liters: 30, total_amount: 165)
        create(:refueling, vehicle: vehicle, vendor: 'Posto Geladão', date: reference_date - 25.days, odometer_km: nil, liters: nil, total_amount: 168)
        create(:refueling, vehicle: vehicle, vendor: 'Posto Geladão', date: reference_date - 20.days, odometer_km: 156_675, liters: 28, total_amount: 168)
        create(:refueling, vehicle: vehicle, vendor: 'Posto Geladão', date: reference_date - 10.days, odometer_km: 156_983, liters: 28, total_amount: 168)
        create(:refueling, vehicle: vehicle, vendor: 'Posto Shell', date: reference_date - 5.days, odometer_km: 157_300, liters: 30, total_amount: 175)
        create(:refueling, vehicle: vehicle, vendor: 'Posto Shell', date: reference_date, odometer_km: 157_620, liters: 30, total_amount: 175)

        result = described_class.new(vehicle: vehicle, date: reference_date).cheapest

        expect(result.winner).to eq('Posto Orense')
      end
    end

    context 'with vendor strings that differ only by whitespace' do
      it 'groups them as the same vendor after normalization' do
        create(:refueling, vehicle: vehicle, vendor: 'Posto Orense', date: reference_date - 60.days, odometer_km: 156_000, liters: 30, total_amount: 165)
        create(:refueling, vehicle: vehicle, vendor: '  Posto   Orense ', date: reference_date - 30.days, odometer_km: 156_345, liters: 30, total_amount: 165)
        create(:refueling, vehicle: vehicle, vendor: 'Posto Geladão', date: reference_date - 20.days, odometer_km: 156_675, liters: 28, total_amount: 168)
        create(:refueling, vehicle: vehicle, vendor: 'Posto Geladão', date: reference_date - 10.days, odometer_km: 156_983, liters: 28, total_amount: 168)
        create(:refueling, vehicle: vehicle, vendor: 'Posto Shell', date: reference_date - 5.days, odometer_km: 157_300, liters: 30, total_amount: 175)
        create(:refueling, vehicle: vehicle, vendor: 'Posto Shell', date: reference_date, odometer_km: 157_620, liters: 30, total_amount: 175)

        result = described_class.new(vehicle: vehicle, date: reference_date).cheapest

        expect(result.winner).to eq('Posto Orense')
      end
    end

    context 'when no readings fall in the last 30 days' do
      it 'estimates zero savings' do
        create(:refueling, vehicle: vehicle, vendor: 'Posto Orense', date: reference_date - 120.days, odometer_km: 150_000, liters: 30, total_amount: 165)
        create(:refueling, vehicle: vehicle, vendor: 'Posto Orense', date: reference_date - 90.days, odometer_km: 150_345, liters: 30, total_amount: 165)
        create(:refueling, vehicle: vehicle, vendor: 'Posto Geladão', date: reference_date - 80.days, odometer_km: 150_675, liters: 28, total_amount: 168)
        create(:refueling, vehicle: vehicle, vendor: 'Posto Geladão', date: reference_date - 70.days, odometer_km: 150_983, liters: 28, total_amount: 168)
        create(:refueling, vehicle: vehicle, vendor: 'Posto Shell', date: reference_date - 60.days, odometer_km: 151_300, liters: 30, total_amount: 175)
        create(:refueling, vehicle: vehicle, vendor: 'Posto Shell', date: reference_date - 50.days, odometer_km: 151_620, liters: 30, total_amount: 175)

        result = described_class.new(vehicle: vehicle, date: reference_date).cheapest

        expect(result.savings).to eq(0)
      end
    end
  end
end
