require 'rails_helper'

RSpec.describe Dashboard::ExpensesCalculator do
  subject(:calculator) { described_class.new(Expense.all) }

  before do
    create(:expense, date: '2025-01-01', amount: 100, vendor: 'Posto Shell')
    create(:expense, date: '2025-01-01', amount: 50,  vendor: 'Posto Shell')
    create(:expense, date: '2025-02-01', amount: 200, vendor: 'Mecânico Zé')
  end

  describe '#call' do
    let(:result) { calculator.call }

    it 'calculates total expenses' do
      expect(result[:total]).to eq(350.0)
    end

    it 'does not return a by_category key' do
      expect(result).not_to have_key(:by_category)
    end
  end

  describe '#monthly_totals' do
    it 'returns a 12-month array of paid expense sums' do
      create(:expense, date: Date.new(2026, 2, 1),  amount: 80, category: 'fuel', paid: true)
      create(:expense, date: Date.new(2026, 2, 28), amount: 20, category: 'fuel', paid: true)
      create(:expense, date: Date.new(2026, 7, 10), amount: 50, category: 'fuel', paid: true)

      scope = Expense.for_year(2026).paid_only
      result = described_class.new(scope).monthly_totals

      expect(result.size).to eq(12)
      expect(result[1]).to eq(100.0)
      expect(result[6]).to eq(50.0)
    end
  end
end
