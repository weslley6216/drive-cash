require 'rails_helper'

RSpec.describe Chat::EarningPersister do
  describe '#persist' do
    it 'returns success with ActionController::Parameters' do
      payload = ActionController::Parameters.new(amount: 200, platform: 'uber', date: '2026-04-22')
      result = described_class.new.persist(payload)

      expect(result.success?).to be true
      expect(result.record).to be_a(Earning)
      expect(result.action).to eq('create_earning')
    end

    it 'returns success with a plain Hash' do
      payload = { 'amount' => 200, 'platform' => 'uber', 'date' => '2026-04-22' }
      result = described_class.new.persist(payload)

      expect(result.success?).to be true
    end

    it 'returns failure for unknown payload type' do
      result = described_class.new.persist(Object.new)

      expect(result.success?).to be false
      expect(result.errors).to be_present
    end

    it 'returns failure when earning is invalid' do
      payload = { 'amount' => '', 'platform' => 'uber', 'date' => '2026-04-22' }
      result = described_class.new.persist(payload)

      expect(result.success?).to be false
      expect(result.errors).to be_present
    end
  end
end
