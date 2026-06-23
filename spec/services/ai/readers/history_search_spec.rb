require 'rails_helper'

RSpec.describe Ai::Readers::HistorySearch do
  describe '#call' do
    it 'returns matching earnings and expenses' do
      user = create(:user)
      create(:earning, user: user, platform: 'uber', date: Date.new(2026, 6, 10))
      create(:expense, user: user, vendor: 'Shell', date: Date.new(2026, 6, 10))

      result = described_class.new({ 'term' => 'shell' }, user: user).call

      expect(result[:expenses].size).to eq(1)
      expect(result[:term]).to eq('shell')
    end

    it 'returns empty arrays when nothing matches' do
      user = create(:user)
      create(:earning, user: user, platform: 'uber', date: Date.new(2026, 6, 10))

      result = described_class.new({ 'term' => 'nada' }, user: user).call

      expect(result[:earnings]).to be_empty
      expect(result[:expenses]).to be_empty
    end

    it 'does not include records from other users' do
      user = create(:user)
      other = create(:user)
      create(:earning, user: other, platform: 'uber', date: Date.new(2026, 6, 10))

      result = described_class.new({ 'term' => 'uber' }, user: user).call

      expect(result[:earnings]).to be_empty
    end
  end
end
