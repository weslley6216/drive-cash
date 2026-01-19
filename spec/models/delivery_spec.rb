# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Delivery, type: :model do
  subject(:delivery) { build(:delivery) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_presence_of(:route_value) }
    it { is_expected.to validate_numericality_of(:route_value).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:fuel_cost).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:maintenance_cost).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:other_costs).is_greater_than_or_equal_to(0) }
  end

  describe 'database aggregations' do
    before do
      create(:delivery, route_value: 100, fuel_cost: 10, maintenance_cost: 5, other_costs: 5)
      create(:delivery, route_value: 200, fuel_cost: 20, maintenance_cost: 0, other_costs: 0)
    end

    it '.total_earnings calculates sum of route_value' do
      expect(Delivery.total_earnings).to eq(300)
    end

    it '.total_expenses calculates sum of all costs using SQL' do
      expect(Delivery.total_expenses).to eq(40)
    end

    it '.total_profit calculates net profit directly from database' do
      expect(Delivery.total_profit).to eq(260)
    end
  end

  describe '.available_years' do
    context 'when there are deliveries' do
      before do
        create(:delivery, date: '2023-01-01')
        create(:delivery, date: '2025-01-01')
      end

      it 'returns distinct years sorted descending' do
        expect(Delivery.available_years).to eq([2025, 2023])
      end
    end

    context 'when there are no deliveries' do
      it 'returns the current year as default' do
        expect(Delivery.available_years).to eq([Date.current.year])
      end
    end
  end

  describe '#total_costs' do
    it 'calculates correctly' do
      delivery = build(:delivery, fuel_cost: 80, maintenance_cost: 20, other_costs: 10)

      expect(delivery.total_costs).to eq(110)
    end
  end
end
