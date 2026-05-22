require 'rails_helper'

RSpec.describe Chat::RecordPersister do
  describe '.for' do
    it 'returns an ExpensePersister for create_expense' do
      result = described_class.for('create_expense')

      expect(result).to be_a(Chat::ExpensePersister)
    end

    it 'returns an EarningPersister for create_earning' do
      result = described_class.for('create_earning')

      expect(result).to be_a(Chat::EarningPersister)
    end

    it 'returns a NullPersister for unknown actions' do
      result = described_class.for('unknown_action')

      expect(result).to be_a(described_class::NullPersister)
    end

    it 'NullPersister returns a failure result' do
      result = described_class.for('unknown_action').persist({})

      expect(result.success?).to be false
      expect(result.errors).to be_present
    end
  end
end
