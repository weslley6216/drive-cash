require 'rails_helper'

RSpec.describe Dashboard::ExpensesCalculator do
  let!(:exp1) { create(:expense, date: '2025-01-01', amount: 100, vendor: 'Posto Shell') }
  let!(:exp2) { create(:expense, date: '2025-01-01', amount: 50, vendor: 'Posto Shell') }
  let!(:exp3) { create(:expense, date: '2025-02-01', amount: 200, vendor: 'Mecânico Zé') }

  subject(:calculator) { described_class.new(Expense.all) }

  describe '#call' do
    let(:result) { calculator.call }

    it 'calculates total expenses' do
      expect(result[:total]).to eq(350.0)
    end

    it 'lists top vendors correctly' do
      expected_vendors = { 'Posto Shell' => 150.0, 'Mecânico Zé' => 200.0 }

      expect(result[:top_vendors]).to include(expected_vendors)
    end
  end
end
