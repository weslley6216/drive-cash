require 'rails_helper'

RSpec.describe Ai::Readers::Summary do
  describe '#call' do
    it 'returns profit/earnings/expenses for the given month' do
      user = create(:user)
      create(:earning, user: user, amount: 500, date: Date.new(2026, 6, 10))
      create(:expense, user: user, amount: 100, date: Date.new(2026, 6, 10))

      result = described_class.new({ 'year' => 2026, 'month' => 6 }, user: user).call

      expect(result[:earnings]).to eq(500.0)
      expect(result[:expenses]).to eq(100.0)
      expect(result[:profit]).to eq(400.0)
    end

    it 'does not include records from other users' do
      user = create(:user)
      other = create(:user)
      create(:earning, user: other, amount: 9999, date: Date.new(2026, 6, 10))

      result = described_class.new({ 'year' => 2026, 'month' => 6 }, user: user).call

      expect(result[:earnings]).to eq(0.0)
    end

    it 'defaults to current year when params are empty' do
      user = create(:user)

      result = described_class.new({}, user: user).call

      expect(result).to have_key(:profit)
    end
  end
end
