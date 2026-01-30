require 'rails_helper'

RSpec.describe Dashboard::ExpensesDetailService do
  describe '#call' do
    context 'with month filter (monthly detail)' do
      let(:trip) { create(:trip) }
      let(:exp1) { create(:expense, trip: trip, date: Date.new(2025, 1, 15), amount: 80, category: 'fuel') }
      let(:exp2) { create(:expense, trip: trip, date: Date.new(2025, 1, 20), amount: 120, category: 'maintenance') }

      subject(:service) { described_class.new(year: 2025, month: 1) }

      before { trip; exp1; exp2 }

      it 'returns expenses list and total' do
        result = service.call

        expect(result[:annual]).to eq(false)
        expect(result[:expenses_by_month]).to be_nil
        expect(result[:expenses].to_a).to match_array([exp1, exp2])
        expect(result[:total]).to eq(200.0)
      end
    end

    context 'without month filter (annual detail)' do
      let(:trip) { create(:trip) }
      let(:jan) { create(:expense, trip: trip, date: Date.new(2025, 1, 10), amount: 100, category: 'fuel') }
      let(:feb1) { create(:expense, trip: trip, date: Date.new(2025, 2, 5), amount: 50, category: 'meals') }
      let(:feb2) { create(:expense, trip: trip, date: Date.new(2025, 2, 20), amount: 150, category: 'maintenance') }

      subject(:service) { described_class.new(year: 2025, month: nil) }

      before { trip; jan; feb1; feb2 }

      it 'returns expenses by month and total' do
        result = service.call

        expect(result[:annual]).to eq(true)
        expect(result[:expenses]).to eq(Expense.none)
        expect(result[:expenses_by_month].size).to eq(2)
        expect(result[:expenses_by_month].map { |r| r[:month_name] }).to include('janeiro', 'fevereiro')
        expect(result[:expenses_by_month].find { |r| r[:month_name] == 'janeiro' }[:total]).to eq(100.0)
        expect(result[:expenses_by_month].find { |r| r[:month_name] == 'fevereiro' }[:total]).to eq(200.0)
        expect(result[:total]).to eq(300.0)
      end
    end
  end
end
