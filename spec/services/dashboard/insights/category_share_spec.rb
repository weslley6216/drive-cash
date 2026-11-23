require 'rails_helper'

RSpec.describe Dashboard::Insights::CategoryShare do
  let(:user) { create(:user) }

  describe '#call' do
    it 'describes the category with the highest amount of the period' do
      categories = [
        { id: 'fuel', label: 'Combustível', amount: 220.0, percent: 52.7 },
        { id: 'toll', label: 'Pedágio', amount: 100.0, percent: 23.9 }
      ]
      context = Dashboard::Insights::Context.new(
        user:          user,
        year:          2025,
        month:         6,
        current_stats: {},
        categories:    categories,
        platforms:     []
      )

      result = described_class.new(context).call

      expect(result[:type]).to eq('category_share')
      expect(result[:payload]).to eq(category_id: 'fuel', category: 'Combustível', percent: 52.7, amount: 220.0, year: 2025, month: 6)
    end

    it 'returns nil when the period has no expenses' do
      context = Dashboard::Insights::Context.new(
        user:          user,
        year:          2025,
        month:         6,
        current_stats: {},
        categories:    [],
        platforms:     []
      )

      expect(described_class.new(context).call).to be_nil
    end
  end
end
