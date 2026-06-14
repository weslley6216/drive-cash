require 'rails_helper'

RSpec.describe Vehicles::MaintenanceService do
  let(:user) { create(:user) }
  let(:reference_date) { Date.new(2026, 6, 15) }

  describe '#call' do
    context 'when user has no vehicle' do
      it 'returns nil for vehicle and empty payload buckets' do
        result = described_class.new(user: user, date: reference_date).call

        expect(result[:vehicle]).to be_nil
        expect(result[:odometer]).to eq(current_km: 0, km_this_month: 0, updated_days_ago: nil)
        expect(result[:maintenances]).to eq([])
        expect(result[:insights]).to eq([])
      end
    end

    context 'when user has a vehicle' do
      let(:vehicle) { create(:vehicle, user: user, odometer_km: 160_928, odometer_updated_at: 3.days.ago) }

      before { vehicle }

      it 'returns vehicle and odometer payload with freshness' do
        create(:refueling, vehicle: vehicle, date: reference_date.beginning_of_month, odometer_km: 159_088)

        result = described_class.new(user: user, date: reference_date).call

        expect(result[:vehicle]).to eq(vehicle)
        expect(result[:odometer][:current_km]).to eq(160_928)
        expect(result[:odometer][:km_this_month]).to eq(1840)
        expect(result[:odometer][:updated_days_ago]).to eq(3)
      end

      it 'returns maintenances ordered by progress descending with status_key' do
        on_track = create(:maintenance, vehicle: vehicle, category: 'timing_belt', last_done_km: 130_000, interval_km: 60_000)
        overdue = create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 150_000, interval_km: 5_000)

        result = described_class.new(user: user, date: reference_date).call

        maintenances = result[:maintenances]
        expect(maintenances.map(&:maintenance)).to eq([overdue, on_track])
        expect(maintenances.first.status_key).to eq(:overdue)
        expect(maintenances.first.km_until).to be_negative
        expect(maintenances.last.status_key).to eq(:ok)
      end

      describe 'cheapest_vendor insight' do
        it 'is returned with the winning vendor and its efficiency when there are at least 3 distinct vendors' do
          base_refuelings_for_three_vendors(vehicle: vehicle, reference_date: reference_date)

          result = described_class.new(user: user, date: reference_date).call

          insight = result[:insights].find { |entry| entry[:type] == :cheapest_vendor }
          expect(insight[:winner]).to eq('Posto Orense')
          expect(insight[:winner_kml]).to be > insight[:runner_up_kml]
        end

        it 'is not returned when fewer than 3 distinct vendors exist' do
          create(:refueling, vehicle: vehicle, vendor: 'Posto Orense', date: reference_date - 30.days, odometer_km: 159_000, full_tank: true)
          create(:refueling, vehicle: vehicle, vendor: 'Posto Orense', date: reference_date, odometer_km: 159_330, full_tank: true)

          result = described_class.new(user: user, date: reference_date).call

          expect(result[:insights]).to be_empty
        end
      end
    end
  end

  def base_refuelings_for_three_vendors(vehicle:, reference_date:)
    create(:refueling, vehicle: vehicle, vendor: 'Posto Orense', date: reference_date - 60.days, odometer_km: 156_000, liters: 30, total_amount: 165, full_tank: true)
    create(:refueling, vehicle: vehicle, vendor: 'Posto Orense', date: reference_date - 30.days, odometer_km: 156_345, liters: 30, total_amount: 165, full_tank: true)
    create(:refueling, vehicle: vehicle, vendor: 'Posto Geladão', date: reference_date - 20.days, odometer_km: 156_675, liters: 28, total_amount: 168, full_tank: true)
    create(:refueling, vehicle: vehicle, vendor: 'Posto Geladão', date: reference_date - 10.days, odometer_km: 156_983, liters: 28, total_amount: 168, full_tank: true)
    create(:refueling, vehicle: vehicle, vendor: 'Posto Shell', date: reference_date - 5.days, odometer_km: 157_300, liters: 30, total_amount: 175, full_tank: true)
    create(:refueling, vehicle: vehicle, vendor: 'Posto Shell', date: reference_date, odometer_km: 157_620, liters: 30, total_amount: 175, full_tank: true)
  end
end
