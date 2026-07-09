require 'rails_helper'

RSpec.describe Expenses::Creator do
  let(:user) { create(:user) }

  describe '.call' do
    context 'when not creating installments' do
      let(:expense_params) do
        {
          date:     '2026-01-10',
          amount:   100.00,
          category: 'fuel',
          vendor:   'Shell'
        }
      end

      it 'creates a single paid expense owned by the user' do
        result = described_class.call(expense_params, {}, user: user)

        expect(result.success?).to be true
        expect(result.expenses.size).to eq(1)
        expect(result.expenses.first.paid).to be true
        expect(result.expenses.first.user).to eq(user)
      end

      it 'returns failure when expense is invalid' do
        result = described_class.call({ amount: -10 }, {}, user: user)

        expect(result.success?).to be false
        expect(result.expense.errors).to be_present
      end

      it 'ignores user_id forged inside the attributes payload' do
        other = create(:user)
        result = described_class.call(expense_params.merge(user_id: other.id), {}, user: user)

        expect(result.expenses.first.user).to eq(user)
      end
    end

    context 'when creating installments' do
      let(:expense_params) do
        {
          date:     '2026-01-10',
          amount:   300.00,
          category: 'maintenance',
          vendor:   'Oficina'
        }
      end

      let(:installment_params) do
        { repeat: true, period: 'monthly', repetitions: 3 }
      end

      it 'delegates to InstallmentCreator passing the user along' do
        result = described_class.call(expense_params, installment_params, user: user)

        expect(result.success?).to be true
        expect(result.expenses.size).to eq(3)
        expect(result.expenses.map(&:user)).to all(eq(user))
      end
    end

    context 'with refueling params on a fuel expense' do
      let(:user) { create(:user) }
      let(:fuel_params) { { date: '2026-06-22', amount: 180.50, category: 'fuel', vendor: 'Posto' } }

      before { create(:vehicle, user: user, odometer_km: 48_000) }

      it 'creates the expense and the linked refueling' do
        result = described_class.call(fuel_params, {}, { liters: '30', odometer_km: '48230', full_tank: '1' }, user: user)

        expect(result.success?).to be(true)
        expect(Refueling.count).to eq(1)
        expect(Refueling.last.expense).to eq(result.expenses.first)
      end

      it 'creates the expense alone when refueling fields are blank' do
        result = described_class.call(fuel_params, {}, { liters: '', odometer_km: '' }, user: user)

        expect(result.success?).to be(true)
        expect(Expense.count).to eq(1)
        expect(Refueling.count).to eq(0)
      end

      it 'rolls back the expense and refueling when the refueling is invalid' do
        result = described_class.call(fuel_params, {}, { liters: '0', odometer_km: '48230' }, user: user)

        expect(result.success?).to be(false)
        expect(result.expense.errors[:base]).to be_present
        expect(Expense.count).to eq(0)
        expect(Refueling.count).to eq(0)
      end
    end
  end
end
