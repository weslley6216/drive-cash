require 'rails_helper'

RSpec.describe Ai::Readers::BestMonth do
  describe '#call' do
    it 'returns best month by profit' do
      user = create(:user)
      create(:earning, user: user, amount: 1000, date: Date.new(2026, 5, 10))
      create(:earning, user: user, amount: 2000, date: Date.new(2026, 6, 10))

      result = described_class.new({}, user: user).call

      expect(result[:year]).to eq(2026)
      expect(result[:month]).to eq(6)
      expect(result[:profit]).to eq(2000.0)
    end

    it 'returns nil when no earnings' do
      user = create(:user)

      result = described_class.new({}, user: user).call

      expect(result).to be_nil
    end

    it 'does not include records from other users' do
      user = create(:user)
      other = create(:user)
      create(:earning, user: other, amount: 9999, date: Date.new(2026, 6, 10))

      result = described_class.new({}, user: user).call

      expect(result).to be_nil
    end
  end
end
