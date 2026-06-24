require 'rails_helper'

RSpec.describe Ai::Readers::PerTrip do
  describe '#call' do
    it 'returns per trip value when earnings exist' do
      user = create(:user)
      create(:earning, user: user, amount: 500, trips_count: 10, date: Date.new(2026, 6, 10))

      result = described_class.new({ 'year' => 2026, 'month' => 6 }, user: user).call

      expect(result).to eq(50.0)
    end

    it 'returns 0 when no trips' do
      user = create(:user)

      result = described_class.new({ 'year' => 2026, 'month' => 6 }, user: user).call

      expect(result).to eq(0)
    end

    it 'does not include records from other users' do
      user = create(:user)
      other = create(:user)
      create(:earning, user: other, amount: 500, trips_count: 10, date: Date.new(2026, 6, 10))

      result = described_class.new({ 'year' => 2026, 'month' => 6 }, user: user).call

      expect(result).to eq(0)
    end
  end
end
