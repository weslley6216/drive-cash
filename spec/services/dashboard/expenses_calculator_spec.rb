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

    it 'lists top vendors by total amount' do
      expect(result[:top_vendors]).to include(
        'Posto Shell' => 150.0,
        'Mecânico Zé' => 200.0
      )
    end
  end
end
