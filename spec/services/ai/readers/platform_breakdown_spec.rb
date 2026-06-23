require 'rails_helper'

RSpec.describe Ai::Readers::PlatformBreakdown do
  describe '#call' do
    it 'returns platform breakdown when earnings exist' do
      user = create(:user)
      create(:earning, user: user, amount: 300, platform: 'uber', date: Date.new(2026, 6, 10))
      create(:earning, user: user, amount: 200, platform: 'shopee', date: Date.new(2026, 6, 10))

      result = described_class.new({ 'year' => 2026, 'month' => 6 }, user: user).call

      expect(result).to be_an(Array)
      expect(result.map { |row| row[:id] }).to include('uber', 'shopee')
    end

    it 'returns empty array when no earnings' do
      user = create(:user)

      result = described_class.new({ 'year' => 2026, 'month' => 6 }, user: user).call

      expect(result).to be_empty
    end

    it 'does not include records from other users' do
      user = create(:user)
      other = create(:user)
      create(:earning, user: other, amount: 300, platform: 'uber', date: Date.new(2026, 6, 10))

      result = described_class.new({ 'year' => 2026, 'month' => 6 }, user: user).call

      expect(result).to be_empty
    end
  end
end
