require 'rails_helper'

RSpec.describe Chat::ExpensePersister do
  describe '#persist' do
    it 'returns success when expense is created' do
      user = create(:user)
      payload = { amount: 100, category: 'fuel', date: '2026-01-10', vendor: 'Shell', user_id: user.id }
      persister = described_class.new

      result = persister.persist(payload)

      expect(result.success?).to be true
      expect(result.record).to be_a(Expense)
      expect(result.action).to eq('create_expense')
    end

    it 'returns failure when expense is invalid' do
      payload = { amount: -10 }
      persister = described_class.new

      result = persister.persist(payload)

      expect(result.success?).to be false
      expect(result.errors).to be_present
    end
  end
end
