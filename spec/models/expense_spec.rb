require 'rails_helper'

RSpec.describe Expense, type: :model do
  describe 'validations' do
    subject { build(:expense) }

    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_presence_of(:amount) }

    it 'rejects amount equal to zero' do
      expense = build(:expense, amount: 0)

      expense.valid?

      expect(expense.errors[:amount]).to be_present
    end

    it 'produces only one error when amount is blank' do
      expense = build(:expense, amount: nil)

      expense.valid?

      expect(expense.errors[:amount].size).to eq(1)
    end
  end

  describe 'enums' do
    it {
      should define_enum_for(:category).with_values(
        car_wash: 0,
        documentation: 1,
        fine: 2,
        fuel: 3,
        insurance: 4,
        maintenance: 5,
        meals: 6,
        parking: 7,
        phone: 8,
        toll: 9,
        other: 10
      ).with_prefix.backed_by_column_of_type(:integer)
    }
  end

  describe '.human_enum_name' do
    it 'returns the translated category name' do
      expect(Expense.human_enum_name(:category, :fuel)).to eq('Combustível')
    end
  end

  describe 'CATEGORIES_BY_GROUP' do
    it 'groups categories correctly' do
      expect(Expense::CATEGORIES_BY_GROUP[:vehicle]).to match_array(
        %w[fuel maintenance car_wash documentation insurance fine parking toll]
      )
      expect(Expense::CATEGORIES_BY_GROUP[:personal_operations]).to match_array(
        %w[meals phone other]
      )
    end
  end

  describe 'installment validation' do
    it 'invalid when series id is set but counts are missing' do
      expense = build(
        :expense,
        installment_series_id: SecureRandom.uuid,
        installment_number: nil,
        installment_count: 3
      )

      expect(expense).not_to be_valid
    end

    it 'invalid when installment number exceeds total' do
      expense = build(
        :expense,
        installment_series_id: SecureRandom.uuid,
        installment_number: 4,
        installment_count: 3
      )

      expect(expense).not_to be_valid
    end

    it 'invalid when installment count exceeds the maximum' do
      expense = build(
        :expense,
        installment_series_id: SecureRandom.uuid,
        installment_number: 1,
        installment_count: Expense::MAX_INSTALLMENTS + 1
      )

      expect(expense).not_to be_valid
    end

    it 'valid at the installment count maximum' do
      expense = build(
        :expense,
        installment_series_id: SecureRandom.uuid,
        installment_number: 1,
        installment_count: Expense::MAX_INSTALLMENTS
      )

      expect(expense).to be_valid
    end
  end

  describe 'scopes' do
    let(:expense_dec_2024) { create(:expense, date: Date.new(2024, 12, 31)) }
    let(:expense_jan_2025) { create(:expense, date: Date.new(2025, 1, 1)) }
    let(:expense_dec_2025) { create(:expense, date: Date.new(2025, 12, 31)) }

    it '.for_year returns expenses with date inside the given year' do
      expense_jan_2025
      expense_dec_2025
      expense_dec_2024

      result = described_class.for_year(2025)

      expect(result).to include(expense_jan_2025, expense_dec_2025)
      expect(result).not_to include(expense_dec_2024)
    end

    it '.for_year returns all when year is blank' do
      expense_jan_2025

      expect(described_class.for_year(nil)).to include(expense_jan_2025)
      expect(described_class.for_year('')).to include(expense_jan_2025)
    end

    it '.for_month returns expenses matching the month' do
      expense_jan_2025
      expense_dec_2025

      result = described_class.for_month(1)

      expect(result).to include(expense_jan_2025)
      expect(result).not_to include(expense_dec_2025)
    end

    let(:paid_jan_2025)   { create(:expense, date: Date.new(2025, 1, 5),  paid: true) }
    let(:unpaid_jan_2025) { create(:expense, date: Date.new(2025, 1, 6),  paid: false) }
    let(:paid_jun_2025)   { create(:expense, date: Date.new(2025, 6, 1),  paid: true) }

    it '.in_period filters by year only when month is nil' do
      paid_jan_2025
      paid_jun_2025
      expense_dec_2024

      result = described_class.in_period(2025)

      expect(result).to include(paid_jan_2025, paid_jun_2025)
      expect(result).not_to include(expense_dec_2024)
    end

    it '.in_period filters by year and month when month is given' do
      paid_jan_2025
      paid_jun_2025

      result = described_class.in_period(2025, 1)

      expect(result).to include(paid_jan_2025)
      expect(result).not_to include(paid_jun_2025)
    end

    it '.paid_in_period filters by paid_only and the given period' do
      paid_jan_2025
      unpaid_jan_2025
      paid_jun_2025

      result = described_class.paid_in_period(2025, 1)

      expect(result).to include(paid_jan_2025)
      expect(result).not_to include(unpaid_jan_2025, paid_jun_2025)
    end

    it '.paid_in_period ignores month when nil' do
      paid_jan_2025
      paid_jun_2025
      unpaid_jan_2025

      result = described_class.paid_in_period(2025)

      expect(result).to include(paid_jan_2025, paid_jun_2025)
      expect(result).not_to include(unpaid_jan_2025)
    end
  end

  describe 'sanitize_amount' do
    it 'converts comma-separated value to float' do
      expense = build(:expense, amount: '45,90')

      expense.valid?

      expect(expense.amount).to eq(45.90)
    end
  end

  describe 'user association' do
    it 'is invalid without a user' do
      expense = build(:expense, user: nil)

      expense.valid?

      expect(expense.errors[:user]).to be_present
    end

    it 'can be associated with a user' do
      user = create(:user)
      expense = create(:expense, user: user)

      expect(expense.user).to eq(user)
    end
  end

  describe 'refueling association' do
    it 'nullifies refueling.expense_id when expense is destroyed' do
      expense = create(:expense, category: 'fuel')
      refueling = create(:refueling, expense: expense)

      expense.destroy

      expect(refueling.reload.expense_id).to be_nil
    end
  end
end
