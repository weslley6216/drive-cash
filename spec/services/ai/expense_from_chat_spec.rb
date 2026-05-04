require 'rails_helper'

RSpec.describe Ai::ExpenseFromChat do
  let(:base) do
    {
      'date' => '2026-01-10',
      'amount' => '90.00',
      'category' => 'maintenance',
      'vendor' => 'Pneus',
      'description' => 'Pneus'
    }
  end

  describe '.persist' do
    it 'creates a single paid expense by default' do
      result = described_class.persist(base)

      expect(result.success?).to be(true)
      expect(result.expenses.size).to eq(1)
      expect(result.expenses.first.paid).to be(true)
    end

    it 'creates installments when installments and period are valid' do
      result = described_class.persist(base.merge('installments' => 3, 'installments_period' => 'monthly'))

      expect(result.success?).to be(true)
      expect(result.expenses.size).to eq(3)
      expect(result.expenses.map(&:paid)).to all(be(false))
    end

    it 'returns errors when installments need a valid period' do
      result = described_class.persist(base.merge('installments' => 3, 'installments_period' => ''))

      expect(result.success?).to be(false)
      expect(result.expense.errors[:base]).to be_present
    end

    it 'returns errors when the expense is invalid' do
      result = described_class.persist(base.merge('amount' => 0))

      expect(result.success?).to be(false)
      expect(result.expense).to be_invalid
    end

    it 'tolerates blank input by treating attributes as empty' do
      result = described_class.persist(nil)

      expect(result.success?).to be(false)
    end

    it 'coerces Parameters objects from the confirmation request' do
      params_obj = ActionController::Parameters.new(
        base.merge('installments' => 2, 'installments_period' => 'weekly')
      )
      params_obj.permit!

      result = described_class.persist(params_obj)

      expect(result.success?).to be(true)
      expect(result.expenses.size).to eq(2)
    end
  end
end
