require 'rails_helper'

RSpec.describe Expenses::UpdateService do
  describe '#call' do
    let(:original_date) { Date.new(2026, 1, 10) }
    let(:expense) { create(:expense, date: original_date, amount: 50, category: 'fuel') }

    it 'updates expense fields' do
      result = described_class.new(
        expense: expense,
        params: { amount: 75, category: 'maintenance', vendor: 'Oficina' }
      ).call

      expect(result.reload.amount).to eq(75.0)
      expect(result.category).to eq('maintenance')
      expect(result.vendor).to eq('Oficina')
    end

    it 'reassigns trip when date changes' do
      new_date = Date.new(2026, 2, 20)

      described_class.new(expense: expense, params: { date: new_date }).call

      expect(expense.reload.trip.date).to eq(new_date)
    end
  end
end
