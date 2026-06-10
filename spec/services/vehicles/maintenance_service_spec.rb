require 'rails_helper'

RSpec.describe Vehicles::MaintenanceService do
  let(:user) { create(:user) }
  let(:reference_date) { Date.new(2026, 6, 15) }

  describe '#call' do
    context 'when user has no vehicle' do
      it 'returns nil for vehicle and empty payload buckets' do
        result = described_class.new(user: user, date: reference_date).call

        expect(result[:vehicle]).to be_nil
        expect(result[:odometer]).to eq(current_km: 0, km_this_month: 0)
        expect(result[:metrics]).to eq(cost_per_km: 0, revenue_per_km: 0, profit_per_km: 0, km_per_liter: nil)
        expect(result[:upcoming_maintenances]).to eq([])
        expect(result[:recent_refuelings]).to eq([])
        expect(result[:insights]).to eq([])
      end
    end

    context 'when user has a vehicle' do
      let(:vehicle) { create(:vehicle, user: user, odometer_km: 48_230) }

      before { vehicle }

      it 'returns vehicle and odometer payload' do
        create(:refueling, vehicle: vehicle, date: reference_date.beginning_of_month, odometer_km: 46_390)

        result = described_class.new(user: user, date: reference_date).call

        expect(result[:vehicle]).to eq(vehicle)
        expect(result[:odometer][:current_km]).to eq(48_230)
        expect(result[:odometer][:km_this_month]).to eq(1840)
      end

      it 'returns metrics from Vehicles::Statistics' do
        create(:refueling, vehicle: vehicle, date: reference_date - 30.days, odometer_km: 47_000, liters: 30, full_tank: true)
        create(:refueling, vehicle: vehicle, date: reference_date,           odometer_km: 47_330, liters: 30, full_tank: true)
        create(:earning, user: user, amount: 610, date: reference_date - 10.days)
        create(:expense, user: user, category: 'fuel', amount: 270, date: reference_date - 5.days)

        result = described_class.new(user: user, date: reference_date).call

        expect(result[:metrics][:km_per_liter]).to be_within(0.1).of(11.0)
        expect(result[:metrics][:cost_per_km]).to be > 0
        expect(result[:metrics][:revenue_per_km]).to be > 0
        expect(result[:metrics][:profit_per_km]).to be_within(0.01).of(result[:metrics][:revenue_per_km] - result[:metrics][:cost_per_km])
      end

      it 'returns pending maintenances with km_until, days_until, urgent, progress_pct' do
        maintenance = create(:maintenance, vehicle: vehicle, due_at_km: 48_500,
                                           due_at_date: reference_date + 8.days)

        result = described_class.new(user: user, date: reference_date).call

        entry = result[:upcoming_maintenances].first
        expect(entry[:maintenance]).to eq(maintenance)
        expect(entry[:km_until]).to eq(270)
        expect(entry[:days_until]).to eq(8)
        expect(entry[:urgent]).to be(true)
        expect(entry[:progress_pct]).to be_between(0, 100)
      end

      it 'excludes completed maintenances' do
        create(:maintenance, vehicle: vehicle, completed: true)

        result = described_class.new(user: user, date: reference_date).call

        expect(result[:upcoming_maintenances]).to be_empty
      end

      it 'returns recent refuelings with computed_km_per_liter' do
        create(:refueling, vehicle: vehicle, date: reference_date - 30.days, odometer_km: 47_000, liters: 30, full_tank: true)
        last = create(:refueling, vehicle: vehicle, date: reference_date, odometer_km: 47_330, liters: 30, full_tank: true)

        result = described_class.new(user: user, date: reference_date).call

        entry = result[:recent_refuelings].first
        expect(entry[:refueling]).to eq(last)
        expect(entry[:computed_km_per_liter]).to be_within(0.05).of(11.0)
      end

      it 'limits recent refuelings to 5 entries' do
        7.times do |offset|
          create(:refueling, vehicle: vehicle, date: reference_date - offset.days,
                             odometer_km: 47_000 + (offset * 100))
        end

        result = described_class.new(user: user, date: reference_date).call

        expect(result[:recent_refuelings].size).to eq(5)
      end

      describe 'cheapest_vendor insight' do
        it 'is returned when there are at least 3 distinct vendors with full_tank pairs' do
          base_refuelings_for_three_vendors(vehicle: vehicle, reference_date: reference_date)

          result = described_class.new(user: user, date: reference_date).call

          insight = result[:insights].find { |entry| entry[:type] == :cheapest_vendor }
          expect(insight).not_to be_nil
          expect(insight[:title]).to include('Posto Orense')
        end

        it 'is not returned when fewer than 3 distinct vendors exist' do
          create(:refueling, vehicle: vehicle, vendor: 'Posto Orense', date: reference_date - 30.days, odometer_km: 47_000, full_tank: true)
          create(:refueling, vehicle: vehicle, vendor: 'Posto Orense', date: reference_date,           odometer_km: 47_330, full_tank: true)

          result = described_class.new(user: user, date: reference_date).call

          expect(result[:insights]).to be_empty
        end
      end
    end
  end

  def base_refuelings_for_three_vendors(vehicle:, reference_date:)
    create(:refueling, vehicle: vehicle, vendor: 'Posto Orense',  date: reference_date - 60.days, odometer_km: 46_000, liters: 30, total_amount: 165, full_tank: true)
    create(:refueling, vehicle: vehicle, vendor: 'Posto Orense',  date: reference_date - 30.days, odometer_km: 46_345, liters: 30, total_amount: 165, full_tank: true)
    create(:refueling, vehicle: vehicle, vendor: 'Posto Geladão', date: reference_date - 20.days, odometer_km: 46_675, liters: 28, total_amount: 168, full_tank: true)
    create(:refueling, vehicle: vehicle, vendor: 'Posto Geladão', date: reference_date - 10.days, odometer_km: 46_983, liters: 28, total_amount: 168, full_tank: true)
    create(:refueling, vehicle: vehicle, vendor: 'Posto Shell',   date: reference_date - 5.days,  odometer_km: 47_300, liters: 30, total_amount: 175, full_tank: true)
    create(:refueling, vehicle: vehicle, vendor: 'Posto Shell',   date: reference_date,           odometer_km: 47_620, liters: 30, total_amount: 175, full_tank: true)
  end
end
