require 'rails_helper'

RSpec.describe Chat::EarningPersister do
  describe '#persist' do
    it 'returns success with ActionController::Parameters owned by the user' do
      user = create(:user)
      payload = ActionController::Parameters.new(amount: 200, platform: 'uber', date: '2026-04-22')

      result = described_class.new.persist(payload, user: user)

      expect(result.success?).to be true
      expect(result.record).to be_a(Earning)
      expect(result.record.user).to eq(user)
      expect(result.action).to eq('create_earning')
    end

    it 'returns success with a plain Hash' do
      user = create(:user)
      payload = { 'amount' => 200, 'platform' => 'uber', 'date' => '2026-04-22' }

      result = described_class.new.persist(payload, user: user)

      expect(result.success?).to be true
      expect(result.record.user).to eq(user)
    end

    it 'returns failure for unknown payload type' do
      user = create(:user)

      result = described_class.new.persist(Object.new, user: user)

      expect(result.success?).to be false
      expect(result.errors).to be_present
    end

    it 'returns failure when earning is invalid' do
      user = create(:user)
      payload = { 'amount' => '', 'platform' => 'uber', 'date' => '2026-04-22' }

      result = described_class.new.persist(payload, user: user)

      expect(result.success?).to be false
      expect(result.errors).to be_present
    end

    it 'returns failure when platform is missing' do
      user = create(:user)
      payload = { 'amount' => 200, 'date' => '2026-04-22' }

      result = described_class.new.persist(payload, user: user)

      expect(result.success?).to be false
      expect(result.errors).to include(a_string_matching(/Plataforma/))
    end

    it 'ignores user_id forged inside the payload and assigns the kwarg user' do
      user = create(:user)
      other = create(:user)
      payload = { 'amount' => 200, 'platform' => 'uber', 'date' => '2026-04-22', 'user_id' => other.id }

      result = described_class.new.persist(payload, user: user)

      expect(result.record.user).to eq(user)
    end

    it 'ignores user_id forged inside ActionController::Parameters' do
      user = create(:user)
      other = create(:user)
      params = ActionController::Parameters.new(amount: 200, platform: 'uber', date: '2026-04-22', user_id: other.id)

      result = described_class.new.persist(params, user: user)

      expect(result.record.user).to eq(user)
    end
  end
end
