require 'rails_helper'

RSpec.describe Expenses::InstallmentCreator do
  let(:user) { create(:user) }
  let(:base) do
    {
      'date' => '2026-01-10',
      'amount' => '300.00',
      'category' => 'maintenance',
      'vendor' => 'Pneus',
      'description' => 'Pneus'
    }
  end

  describe '.call' do
    it 'creates N unpaid installments with split amounts and spaced dates' do
      result = described_class.call(base, { period: 'monthly', repetitions: 3 }, user: user)

      expect(result.success?).to be(true)
      expect(result.expenses.size).to eq(3)

      series_ids = result.expenses.map(&:installment_series_id).uniq
      expect(series_ids.size).to eq(1)

      expect(result.expenses.map(&:paid)).to all(be(false))
      expect(result.expenses.map(&:amount).sum).to eq(BigDecimal('300'))
      expect(result.expenses.map(&:date)).to eq([
                                                  Date.new(2026, 1, 10),
                                                  Date.new(2026, 2, 10),
                                                  Date.new(2026, 3, 10)
                                                ])
      expect(result.expenses.map { |expense| [expense.installment_number, expense.installment_count] }.uniq).to eq([[1, 3], [2, 3], [3, 3]])
    end

    it 'spaces weekly installments' do
      result = described_class.call(base, { period: 'weekly', repetitions: 3 }, user: user)
      dates = result.expenses.map(&:date)

      expect(dates.first + 2.weeks).to eq(dates[2])
    end

    it 'spaces biweekly installments' do
      result = described_class.call(base, { period: 'biweekly', repetitions: 3 }, user: user)
      dates = result.expenses.map(&:date)

      expect(dates[1]).to eq(dates[0] + 2.weeks)
      expect(dates[2]).to eq(dates[0] + 4.weeks)
    end

    it 'spaces annual installments from the first due date' do
      result = described_class.call(base, { period: 'annual', repetitions: 2 }, user: user)

      expect(result.expenses.map(&:date)).to eq([Date.new(2026, 1, 10), Date.new(2027, 1, 10)])
    end

    it 'returns failure when repetitions are insufficient' do
      result = described_class.call(base, { period: 'monthly', repetitions: 1 }, user: user)

      expect(result.success?).to be(false)
      expect(result.expense.errors[:base]).to be_present
    end

    it 'returns failure with max error when count exceeds MAX_INSTALLMENTS without creating rows' do
      expect {
        @result = described_class.call(base, { period: 'monthly', repetitions: Expenses::InstallmentPlan::MAX_INSTALLMENTS + 1 }, user: user)
      }.not_to change(Expense, :count)

      expect(@result.success?).to be(false)
      expect(@result.expense.errors[:base]).to include(I18n.t('expenses.installments.errors.invalid_repeat_max'))
    end

    it 'persists installments owned by the given user' do
      result = described_class.call(base, { period: 'monthly', repetitions: 2 }, user: user)

      expect(result.expenses.map(&:user)).to all(eq(user))
    end

    it 'ignores user_id forged inside the attributes payload' do
      other = create(:user)
      result = described_class.call(base.merge('user_id' => other.id), { period: 'monthly', repetitions: 2 }, user: user)

      expect(result.expenses.map(&:user_id)).to all(eq(user.id))
    end

    it 'returns failure when save! raises RecordInvalid' do
      invalid = Expense.new
      invalid.errors.add(:base, 'falhou teste')
      allow_any_instance_of(Expense).to receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(invalid))

      result = described_class.call(base, { period: 'monthly', repetitions: 2 }, user: user)

      expect(result.success?).to be(false)
      expect(result.expense.errors[:base].join).to include('falhou teste')
    end
  end
end
