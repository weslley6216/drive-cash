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

  describe 'total_costs' do
    it 'calculates total costs correctly' do
      delivery = build(:delivery, fuel_cost: 80, maintenance_cost: 20, other_costs: 10)

      expect(delivery.total_costs).to eq(110)
    end
  end

  describe '#net_profit' do
    it 'calculates net profit correctly' do
      delivery = build(:delivery, route_value: 300, fuel_cost: 80, maintenance_cost: 20, other_costs: 10)

      expect(delivery.net_profit).to eq(190)
    end
  end
end
