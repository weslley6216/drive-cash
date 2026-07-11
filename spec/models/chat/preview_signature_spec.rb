require 'rails_helper'

RSpec.describe Chat::PreviewSignature do
  describe '.from' do
    it 'canonicalizes action and params to strings' do
      signature = described_class.from(action: :create_earning, params: { amount: 80, platform: 'uber' })

      expect(signature.action).to eq('create_earning')
      expect(signature.params).to eq('amount' => '80', 'platform' => 'uber')
    end
  end

  describe '#matches?' do
    it 'is true for the same action and equivalent params regardless of value type' do
      one = described_class.from(action: 'create_earning', params: { 'amount' => 80, 'platform' => 'uber' })
      two = described_class.from(action: 'create_earning', params: { 'amount' => '80', 'platform' => 'uber' })

      expect(one.matches?(two)).to be(true)
    end

    it 'is false when the action differs' do
      one = described_class.from(action: 'create_earning', params: { 'amount' => '80' })
      two = described_class.from(action: 'create_expense', params: { 'amount' => '80' })

      expect(one.matches?(two)).to be(false)
    end

    it 'is false when the params differ' do
      one = described_class.from(action: 'create_earning', params: { 'amount' => '80', 'platform' => 'uber' })
      two = described_class.from(action: 'create_earning', params: { 'amount' => '45', 'platform' => 'ifood' })

      expect(one.matches?(two)).to be(false)
    end
  end

  describe '#to_session_hash' do
    it 'round-trips through a session-safe hash' do
      signature = described_class.from(action: 'create_earning', params: { 'amount' => 80 })

      restored = described_class.from(**signature.to_session_hash.symbolize_keys)

      expect(restored.matches?(signature)).to be(true)
    end
  end
end
