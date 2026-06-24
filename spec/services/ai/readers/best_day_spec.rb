require 'rails_helper'

RSpec.describe Ai::Readers::BestDay do
  describe '#call' do
    it 'returns date and amount of best earning day' do
      user = create(:user)
      create(:earning, user: user, amount: 200, date: Date.new(2026, 6, 10))
      create(:earning, user: user, amount: 500, date: Date.new(2026, 6, 15))
      create(:earning, user: user, amount: 100, date: Date.new(2026, 6, 20))

      result = described_class.new({ 'year' => 2026, 'month' => 6 }, user: user).call

      expect(result[:date]).to eq(Date.new(2026, 6, 15))
      expect(result[:amount]).to eq(500.0)
    end

    it 'returns nil when no earnings in period' do
      user = create(:user)

      result = described_class.new({ 'year' => 2026, 'month' => 6 }, user: user).call

      expect(result).to be_nil
    end

    it 'does not include records from other users' do
      user = create(:user)
      other = create(:user)
      create(:earning, user: other, amount: 9999, date: Date.new(2026, 6, 10))

      result = described_class.new({ 'year' => 2026, 'month' => 6 }, user: user).call

      expect(result).to be_nil
    end
  end
end
