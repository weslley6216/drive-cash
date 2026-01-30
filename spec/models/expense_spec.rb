# spec/models/expense_spec.rb
require 'rails_helper'

RSpec.describe Expense, type: :model do
  describe 'validations' do
    subject { build(:expense) }

    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_numericality_of(:amount).is_greater_than(0) }
  end

  describe 'associations' do
    it { should belong_to(:trip) }
  end

  describe 'enums' do
    it { should define_enum_for(:category).with_values(
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
    ).with_prefix.backed_by_column_of_type(:integer) }
  end

  describe '.human_enum_name' do
    it 'returns translated category name' do
      expect(Expense.human_enum_name(:category, :fuel))
        .to eq('Combustível')
    end
  end

  describe 'CATEGORIES_BY_GROUP' do
    it 'groups categories correctly' do
      expect(Expense::CATEGORIES_BY_GROUP[:vehicle]).to match_array(
        %w[
            maintenance
            fuel
            car_wash
            documentation
            insurance
            fine
            parking
            toll
          ]
      )
      expect(Expense::CATEGORIES_BY_GROUP[:personal_operations]).to match_array(%w[meals phone other])
    end
  end

  describe 'scopes' do
    let(:fuel) { create(:expense, category: 'fuel') }
    let(:maintenance) { create(:expense, category: 'maintenance') }

    before { fuel; maintenance }

    it '.by_category filters correctly' do
      expect(described_class.by_category('fuel')).to include(fuel)
      expect(described_class.by_category('fuel')).not_to include(maintenance)
    end
  end

  describe '.total_by_category' do
    before do
      create(:expense, category: 'fuel', amount: 100)
      create(:expense, category: 'fuel', amount: 50)
      create(:expense, category: 'maintenance', amount: 200)
    end

    it 'groups and sums amounts' do
      result = described_class.total_by_category
      expect(result['fuel']).to eq(150.0)
      expect(result['maintenance']).to eq(200.0)
    end
  end
end
