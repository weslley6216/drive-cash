require 'rails_helper'

RSpec.describe Ai::Readers::GoalProgress do
  describe '#call' do
    it 'returns progress data when user has an active goal' do
      user = create(:user)
      create(:goal, user: user, kind: 'monthly', metric: 'profit', target_amount: 3000,
             period_start: Date.new(2026, 6, 1), period_end: Date.new(2026, 6, 30))

      result = described_class.new({}, user: user).call

      expect(result).to have_key(:monthly)
    end

    it 'returns all nil slices when user has no active goals' do
      user = create(:user)

      result = described_class.new({}, user: user).call

      expect(result[:monthly]).to be_nil
      expect(result[:annual]).to be_nil
      expect(result[:weekly]).to be_nil
    end

    it 'does not include goals from other users' do
      user = create(:user)
      other = create(:user)
      create(:goal, user: other, kind: 'monthly', metric: 'profit', target_amount: 3000,
             period_start: Date.new(2026, 6, 1), period_end: Date.new(2026, 6, 30))

      result = described_class.new({}, user: user).call

      expect(result[:monthly]).to be_nil
    end
  end
end
