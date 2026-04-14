require 'rails_helper'

RSpec.describe Expenses::CreateService do
  describe '#call' do
    let(:params) do
      {
        date: Date.new(2026, 1, 23),
        amount: 150.50,
        category: 'maintenance',
        vendor: 'Oficina do Joao',
        description: 'Troca de oleo'
      }
    end

    it 'creates expense and trip when date has no trip' do
      expect {
        described_class.new(params: params).call
      }.to change(Expense, :count).by(1)
       .and change(Trip, :count).by(1)
    end

    it 'reuses existing trip for the same date' do
      trip = create(:trip, date: params[:date])

      expense = described_class.new(params: params).call

      expect(expense.trip).to eq(trip)
      expect(Trip.where(date: params[:date]).count).to eq(1)
    end

    it 'returns unsaved expense for invalid params' do
      invalid_params = params.merge(amount: 0)

      expense = described_class.new(params: invalid_params).call

      expect(expense).not_to be_persisted
      expect(expense.errors).to be_present
    end
  end
end
