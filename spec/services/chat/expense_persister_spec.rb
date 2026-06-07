require 'rails_helper'

RSpec.describe Chat::ExpensePersister do
  describe '#persist' do
    it 'returns success when expense is created and owned by the user' do
      user = create(:user)
      payload = { amount: 100, category: 'fuel', date: '2026-01-10', vendor: 'Shell' }

      result = described_class.new.persist(payload, user: user)

      expect(result.success?).to be true
      expect(result.record).to be_a(Expense)
      expect(result.record.user).to eq(user)
      expect(result.action).to eq('create_expense')
    end

    it 'returns failure when expense is invalid' do
      user = create(:user)
      payload = { amount: -10 }

      result = described_class.new.persist(payload, user: user)

      expect(result.success?).to be false
      expect(result.errors).to be_present
    end

    it 'ignores user_id forged inside the payload and assigns the kwarg user' do
      user = create(:user)
      other = create(:user)
      payload = { amount: 100, category: 'fuel', date: '2026-01-10', vendor: 'Shell', user_id: other.id }

      result = described_class.new.persist(payload, user: user)

      expect(result.record.user).to eq(user)
    end
  end
end
