require 'rails_helper'

RSpec.describe Ai::Readers::UnpaidExpenses do
  describe '#call' do
    it 'returns unpaid expenses ordered by date' do
      user = create(:user)
      create(:expense, user: user, amount: 100, paid: false, date: Date.new(2026, 6, 10))
      create(:expense, user: user, amount: 50, paid: true, date: Date.new(2026, 6, 11))

      result = described_class.new({}, user: user).call

      expect(result.size).to eq(1)
      expect(result.first.amount).to eq(100)
    end

    it 'returns empty array when all expenses are paid' do
      user = create(:user)
      create(:expense, user: user, amount: 100, paid: true, date: Date.new(2026, 6, 10))

      result = described_class.new({}, user: user).call

      expect(result).to be_empty
    end

    it 'does not include expenses from other users' do
      user = create(:user)
      other = create(:user)
      create(:expense, user: other, amount: 100, paid: false, date: Date.new(2026, 6, 10))

      result = described_class.new({}, user: user).call

      expect(result).to be_empty
    end
  end
end
