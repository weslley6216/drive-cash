require 'rails_helper'

RSpec.describe Dashboard::Insights::Context do
  describe 'attributes' do
    it 'exposes all fields passed in' do
      user = create(:user)
      context = described_class.new(
        user: user,
        year: 2025,
        month: 6,
        previous_year: 2024,
        previous_month: 6,
        current_stats: { profit: 100 },
        previous_stats: { profit: 50 },
        categories: [{ id: 'fuel', amount: 200 }],
        platforms:  [{ id: 'uber', amount: 500 }]
      )

      expect(context.user).to eq(user)
      expect(context.year).to eq(2025)
      expect(context.month).to eq(6)
      expect(context.previous_year).to eq(2024)
      expect(context.previous_month).to eq(6)
      expect(context.current_stats[:profit]).to eq(100)
      expect(context.previous_stats[:profit]).to eq(50)
      expect(context.categories.first[:id]).to eq('fuel')
      expect(context.platforms.first[:id]).to eq('uber')
    end
  end
end
