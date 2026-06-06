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
end
