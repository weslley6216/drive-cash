require 'rails_helper'

RSpec.describe Ai::Readers::CategoryTotal do
  describe '#call' do
    it 'sums the paid expenses of the category in the month' do
      user = create(:user)
      create(:expense, user: user, category: 'fuel', amount: 200, date: Date.new(2026, 6, 3))
      create(:expense, user: user, category: 'fuel', amount: 120, date: Date.new(2026, 6, 20))
      create(:expense, user: user, category: 'fuel', amount: 90, date: Date.new(2026, 6, 21), paid: false)
      create(:expense, user: user, category: 'toll', amount: 15, date: Date.new(2026, 6, 3))
      create(:expense, user: user, category: 'fuel', amount: 70, date: Date.new(2026, 5, 30))
      create(:expense, user: create(:user), category: 'fuel', amount: 999, date: Date.new(2026, 6, 3))

      result = described_class.new({ 'category' => 'fuel', 'year' => 2026, 'month' => 6 }, user: user).call

      expect(result).to eq(category: 'fuel', total: 320.0)
    end

    it 'sums the whole year when no month is given' do
      user = create(:user)
      create(:expense, user: user, category: 'fuel', amount: 200, date: Date.new(2026, 6, 3))
      create(:expense, user: user, category: 'fuel', amount: 70, date: Date.new(2026, 5, 30))
      create(:expense, user: user, category: 'fuel', amount: 40, date: Date.new(2025, 12, 30))

      result = described_class.new({ 'category' => 'fuel', 'year' => 2026 }, user: user).call

      expect(result).to eq(category: 'fuel', total: 270.0)
    end

    it 'returns nil for a category that is not an expense category' do
      result = described_class.new({ 'category' => 'oil_change' }, user: create(:user)).call

      expect(result).to be_nil
    end
  end
end
