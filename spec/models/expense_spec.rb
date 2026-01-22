# spec/models/expense_spec.rb
require 'rails_helper'

RSpec.describe Expense, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_presence_of(:category) }
    it { is_expected.to validate_numericality_of(:amount).is_greater_than_or_equal_to(0) }
    it { is_expected.to define_enum_for(:category).with_prefix.backed_by_column_of_type(:string) }
  end

  describe 'scopes' do
    let!(:fuel) { create(:expense, category: 'fuel') }
    let!(:maintenance) { create(:expense, category: 'maintenance') }

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
