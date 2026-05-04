require 'rails_helper'

RSpec.describe Expenses::Creator do
  describe '.call' do
    context 'when not creating installments' do
      let(:expense_params) do
        {
          date: '2026-01-10',
          amount: 100.00,
          category: 'fuel',
          vendor: 'Shell'
        }
      end

      it 'creates a single paid expense' do
        result = described_class.call(expense_params, {})

        expect(result.success?).to be true
        expect(result.expenses.size).to eq(1)
        expect(result.expenses.first.paid).to be true
      end

      it 'returns failure when expense is invalid' do
        result = described_class.call({ amount: -10 }, {})

        expect(result.success?).to be false
        expect(result.expense.errors).to be_present
      end
    end

    context 'when creating installments' do
      let(:expense_params) do
        {
          date: '2026-01-10',
          amount: 300.00,
          category: 'maintenance',
          vendor: 'Oficina'
        }
      end

      let(:installment_params) do
        { repeat: true, period: 'monthly', repetitions: 3 }
      end

      it 'delegates to InstallmentCreator' do
        result = described_class.call(expense_params, installment_params)

        expect(result.success?).to be true
        expect(result.expenses.size).to eq(3)
      end
    end
  end
end
