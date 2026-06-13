require 'rails_helper'

RSpec.describe Chat::Payload do
  describe '.permit' do
    let(:keys) { %i[date amount platform] }

    it 'permits and stringifies ActionController::Parameters, dropping unlisted keys' do
      raw = ActionController::Parameters.new(amount: 200, platform: 'uber', date: '2026-04-22', user_id: 99)

      result = described_class.permit(raw, keys)

      expect(result).to eq('amount' => 200, 'platform' => 'uber', 'date' => '2026-04-22')
    end

    it 'slices a hash to the listed keys regardless of key type' do
      raw = { amount: 200, 'platform' => 'uber', user_id: 99 }

      result = described_class.permit(raw, keys)

      expect(result).to eq('amount' => 200, 'platform' => 'uber')
    end

    it 'returns an empty hash for unsupported input' do
      expect(described_class.permit(Object.new, keys)).to eq({})
    end
  end
end
