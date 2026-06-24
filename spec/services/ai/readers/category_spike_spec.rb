require 'rails_helper'

RSpec.describe Ai::Readers::CategorySpike do
  describe '#call' do
    it 'returns spike data when a category increased significantly' do
      user = create(:user)
      create(:expense, user: user, amount: 50, category: 'fuel', date: Date.new(2026, 5, 10), paid: true)
      create(:expense, user: user, amount: 200, category: 'fuel', date: Date.new(2026, 6, 10), paid: true)

      result = described_class.new({ 'year' => 2026, 'month' => 6 }, user: user).call

      expect(result).not_to be_nil
      expect(result[:category]).to be_present
      expect(result[:pct]).to be > 10
    end

    it 'returns nil when no expenses' do
      user = create(:user)

      result = described_class.new({ 'year' => 2026, 'month' => 6 }, user: user).call

      expect(result).to be_nil
    end

    it 'does not include records from other users' do
      user = create(:user)
      other = create(:user)
      create(:expense, user: other, amount: 50, category: 'fuel', date: Date.new(2026, 5, 10), paid: true)
      create(:expense, user: other, amount: 200, category: 'fuel', date: Date.new(2026, 6, 10), paid: true)

      result = described_class.new({ 'year' => 2026, 'month' => 6 }, user: user).call

      expect(result).to be_nil
    end
  end
end
