require 'rails_helper'

RSpec.describe Chat::GoalPersister do
  describe '#persist' do
    it 'creates a goal and returns success' do
      user = create(:user)
      payload = { 'kind' => 'monthly', 'target_amount' => 3000.0, 'metric' => 'profit' }

      result = described_class.new.persist(payload, user: user)

      expect(result.success?).to be true
      expect(result.record).to be_a(Goal)
      expect(result.action).to eq('create_goal')
    end

    it 'returns failure when goal is invalid' do
      user = create(:user)
      payload = { 'kind' => 'invalid', 'target_amount' => 100.0 }

      result = described_class.new.persist(payload, user: user)

      expect(result.success?).to be false
      expect(result.errors).to be_present
    end

    it 'associates goal to the given user' do
      user = create(:user)
      payload = { 'kind' => 'monthly', 'target_amount' => 2000.0 }

      result = described_class.new.persist(payload, user: user)

      expect(result.record.user).to eq(user)
    end
  end
end
