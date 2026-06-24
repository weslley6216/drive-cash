require 'rails_helper'

RSpec.describe Ai::Readers::MarginDrop do
  describe '#call' do
    it 'returns margin drop data when margin decreased significantly' do
      user = create(:user)
      create(:earning, user: user, amount: 1000, date: Date.new(2026, 5, 10))
      create(:expense, user: user, amount: 100, date: Date.new(2026, 5, 10), paid: true)
      create(:earning, user: user, amount: 1000, date: Date.new(2026, 6, 10))
      create(:expense, user: user, amount: 500, date: Date.new(2026, 6, 10), paid: true)

      result = described_class.new({ 'year' => 2026, 'month' => 6 }, user: user).call

      expect(result).not_to be_nil
      expect(result[:pp]).to be_present
      expect(result[:current_margin]).to be_present
    end

    it 'returns nil when no prior period data' do
      user = create(:user)
      create(:earning, user: user, amount: 1000, date: Date.new(2026, 6, 10))

      result = described_class.new({ 'year' => 2026, 'month' => 6 }, user: user).call

      expect(result).to be_nil
    end

    it 'does not include records from other users' do
      user = create(:user)
      other = create(:user)
      create(:earning, user: other, amount: 1000, date: Date.new(2026, 5, 10))
      create(:expense, user: other, amount: 100, date: Date.new(2026, 5, 10), paid: true)
      create(:earning, user: other, amount: 1000, date: Date.new(2026, 6, 10))
      create(:expense, user: other, amount: 500, date: Date.new(2026, 6, 10), paid: true)

      result = described_class.new({ 'year' => 2026, 'month' => 6 }, user: user).call

      expect(result).to be_nil
    end
  end
end
