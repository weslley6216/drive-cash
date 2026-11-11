require 'rails_helper'

RSpec.describe Notifications::PreferenceUpdater do
  let(:user) { create(:user) }

  describe '.call' do
    it 'disables a kind' do
      result = described_class.call(user: user, kind: 'tank_low', enabled: 'false')

      expect(result.success?).to be(true)
      expect(user.reload.notification_preferences).to eq('tank_low' => false)
    end

    it 're-enables a kind' do
      user.update!(notification_preferences: { 'tank_low' => false })

      result = described_class.call(user: user, kind: 'tank_low', enabled: 'true')

      expect(result.success?).to be(true)
      expect(user.reload.notification_preferences).to eq({})
    end

    it 'fails for an unknown kind' do
      result = described_class.call(user: user, kind: 'foo', enabled: 'false')

      expect(result.success?).to be(false)
      expect(user.reload.notification_preferences).to eq({})
    end
  end
end
