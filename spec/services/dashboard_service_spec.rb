# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DashboardService do
  let(:deliveries) { Delivery.all }
  subject(:service_call) { described_class.new(deliveries).call }

  describe '#call' do
    context 'when there are deliveries in different months' do
      before do
        create(:delivery, date: '2025-01-10', route_value: 100, fuel_cost: 20, maintenance_cost: 0, other_costs: 0)
        create(:delivery, date: '2025-02-15', route_value: 200, fuel_cost: 30, maintenance_cost: 0, other_costs: 0)
      end

      it 'calculates total profit correctly' do
        expect(service_call[:profit]).to eq(250)
      end

      it 'calculates average earnings per month' do
        expect(service_call[:earnings_avg_month]).to eq(150)
      end

      it 'calculates expenses percentage over revenue' do
        expect(service_call[:expenses_percent]).to eq(16.7)
      end
    end

    context 'when there are no deliveries' do
      it 'returns zeroed values' do
        expect(service_call[:earnings]).to eq(0)
        expect(service_call[:profit_per_day]).to eq(0)
        expect(service_call[:expenses_percent]).to eq(0)
      end
    end
  end
end
