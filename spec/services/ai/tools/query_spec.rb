require 'rails_helper'

RSpec.describe Ai::Tools::Query do
  describe '.declaration' do
    it 'names the tool query' do
      declaration = described_class.declaration

      expect(declaration[:name]).to eq('query')
    end

    it 'declares type as required enum with the 18 kinds' do
      declaration = described_class.declaration
      type_param = declaration[:parameters][:properties][:type]

      expect(declaration[:parameters][:required]).to eq(['type'])
      expect(type_param[:type]).to eq('STRING')
      expect(type_param[:enum]).to match_array(%w[
        summary vendor_efficiency best_day worst_platform category_spike
        margin_drop per_km per_trip tank_balance last_full_tank
        goal_progress platform_breakdown best_month unpaid_expenses
        maintenance_status last_maintenance history_search category_total
      ])
    end

    it 'attaches a non-empty description to each enum value via the type description' do
      declaration = described_class.declaration

      expect(declaration[:parameters][:properties][:type][:description]).to be_present
    end

    it 'declares year, month, term and category as optional params' do
      declaration = described_class.declaration
      properties = declaration[:parameters][:properties]

      expect(properties[:year][:type]).to eq('INTEGER')
      expect(properties[:month][:type]).to eq('INTEGER')
      expect(properties[:term][:type]).to eq('STRING')
      expect(properties[:category][:type]).to eq('STRING')
      expect(declaration[:parameters][:required]).not_to include('year', 'month', 'term', 'category')
    end

    it 'lists the expense categories in the category description for category_total' do
      description = described_class.declaration[:parameters][:properties][:category][:description]

      expect(description).to include('category_total').and include(*Expense.categories.keys)
    end
  end
end
