require 'rails_helper'

RSpec.describe Dashboard::ExpensesDetailService do
  let(:user) { create(:user) }

  describe '#call' do
    context 'with month filter' do
      it 'lists only paid expenses in the monthly view' do
        paid = create(:expense, user: user, date: Date.new(2025, 1, 15), amount: 80, category: 'fuel', paid: true)
        create(:expense, user: user, date: Date.new(2025, 1, 20), amount: 120, category: 'maintenance', paid: false)

        result = described_class.new(year: 2025, month: 1, user: user).call

        expect(result[:expenses].to_a).to eq([paid])
        expect(result[:total]).to eq(80.0)
      end

      it 'includes all expenses when none are unpaid' do
        expense1 = create(:expense, user: user, date: Date.new(2025, 1, 15), amount: 80, category: 'fuel', paid: true)
        expense2 = create(:expense, user: user, date: Date.new(2025, 1, 20), amount: 120, category: 'maintenance', paid: true)

        result = described_class.new(year: 2025, month: 1, user: user).call

        expect(result[:expenses].to_a).to match_array([expense1, expense2])
        expect(result[:total]).to eq(200.0)
      end
    end

    context 'without month filter' do
      it 'returns expenses grouped by month and total' do
        create(:expense, user: user, date: Date.new(2025, 1, 10), amount: 100, category: 'fuel')
        create(:expense, user: user, date: Date.new(2025, 2, 5), amount: 50, category: 'meals')
        create(:expense, user: user, date: Date.new(2025, 2, 20), amount: 150, category: 'maintenance')

        result = described_class.new(year: 2025, month: nil, user: user).call

        expect(result[:annual]).to eq(true)
        expect(result[:expenses]).to eq(Expense.none)
        expect(result[:expenses_by_month].size).to eq(2)
        expect(result[:expenses_by_month].map { |row| row[:month_name] }).to include('janeiro', 'fevereiro')
        expect(result[:expenses_by_month].find { |row| row[:month_name] == 'janeiro' }[:total]).to eq(100.0)
        expect(result[:expenses_by_month].find { |row| row[:month_name] == 'fevereiro' }[:total]).to eq(200.0)
        expect(result[:total]).to eq(300.0)
      end
    end
  end
end
