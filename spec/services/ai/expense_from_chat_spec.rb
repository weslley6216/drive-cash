require 'rails_helper'

RSpec.describe Ai::ExpenseFromChat do
  let(:user) { create(:user) }
  let(:base) do
    {
      'date'        => '2026-01-10',
      'amount'      => '90.00',
      'category'    => 'maintenance',
      'vendor'      => 'Pneus',
      'description' => 'Pneus'
    }
  end

  describe '.persist' do
    it 'creates a single paid expense owned by the user' do
      result = described_class.persist(base, user: user)

      expect(result.success?).to be(true)
      expect(result.expenses.size).to eq(1)
      expect(result.expenses.first.paid).to be(true)
      expect(result.expenses.first.user).to eq(user)
    end

    it 'creates installments when installments and period are valid' do
      result = described_class.persist(base.merge('installments' => 3, 'installments_period' => 'monthly'), user: user)

      expect(result.success?).to be(true)
      expect(result.expenses.size).to eq(3)
      expect(result.expenses.map(&:paid)).to all(be(false))
      expect(result.expenses.map(&:user)).to all(eq(user))
    end

    it 'returns errors when installments need a valid period' do
      result = described_class.persist(base.merge('installments' => 3, 'installments_period' => ''), user: user)

      expect(result.success?).to be(false)
      expect(result.expense.errors[:base]).to be_present
    end

    it 'returns errors when the expense is invalid' do
      result = described_class.persist(base.merge('amount' => 0), user: user)

      expect(result.success?).to be(false)
      expect(result.expense).to be_invalid
    end

    it 'tolerates blank input by treating attributes as empty' do
      result = described_class.persist(nil, user: user)

      expect(result.success?).to be(false)
    end

    it 'coerces Parameters objects from the confirmation request' do
      params_obj = ActionController::Parameters.new(
        base.merge('installments' => 2, 'installments_period' => 'weekly')
      )
      params_obj.permit!

      result = described_class.persist(params_obj, user: user)

      expect(result.success?).to be(true)
      expect(result.expenses.size).to eq(2)
    end

    it 'ignores unknown keys from LLM payload when receiving Parameters' do
      params_obj = ActionController::Parameters.new(
        base.merge('malicious_key' => 'injected', 'admin' => true)
      )

      result = described_class.persist(params_obj, user: user)

      expense = result.expenses.first
      expect(expense).not_to respond_to(:malicious_key)
      expect(expense).not_to respond_to(:admin)
    end

    it 'discards user_id forged inside the payload and keeps the kwarg user' do
      other = create(:user)
      result = described_class.persist(base.merge('user_id' => other.id), user: user)

      expect(result.expenses.first.user).to eq(user)
    end

    it 'discards user_id forged inside ActionController::Parameters' do
      other = create(:user)
      params_obj = ActionController::Parameters.new(base.merge('user_id' => other.id))

      result = described_class.persist(params_obj, user: user)

      expect(result.expenses.first.user).to eq(user)
    end
  end
end
