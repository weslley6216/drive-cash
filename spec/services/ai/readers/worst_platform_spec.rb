require 'rails_helper'

RSpec.describe Ai::Readers::WorstPlatform do
  describe '#call' do
    it 'returns the worst platform per trip when multiple platforms exist' do
      user = create(:user)
      create(:earning, user: user, amount: 1000, platform: 'uber', trips_count: 10, date: Date.new(2026, 6, 10))
      create(:earning, user: user, amount: 200, platform: 'shopee', trips_count: 10, date: Date.new(2026, 6, 10))

      result = described_class.new({ 'year' => 2026, 'month' => 6 }, user: user).call

      expect(result[:platform]).to be_present
      expect(result[:per_trip]).to be_present
    end

    it 'returns nil when only one platform' do
      user = create(:user)
      create(:earning, user: user, amount: 200, platform: 'uber', trips_count: 5, date: Date.new(2026, 6, 10))

      result = described_class.new({ 'year' => 2026, 'month' => 6 }, user: user).call

      expect(result).to be_nil
    end

    it 'returns nil when no earnings' do
      user = create(:user)

      result = described_class.new({ 'year' => 2026, 'month' => 6 }, user: user).call

      expect(result).to be_nil
    end

    it 'does not include records from other users' do
      user = create(:user)
      other = create(:user)
      create(:earning, user: other, amount: 1000, platform: 'uber', trips_count: 10, date: Date.new(2026, 6, 10))
      create(:earning, user: other, amount: 200, platform: 'shopee', trips_count: 10, date: Date.new(2026, 6, 10))

      result = described_class.new({ 'year' => 2026, 'month' => 6 }, user: user).call

      expect(result).to be_nil
    end
  end
end
