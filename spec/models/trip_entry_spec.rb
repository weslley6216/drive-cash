require 'rails_helper'

RSpec.describe TripEntry, type: :model do
  subject(:trip_entry) { described_class.new(attributes) }

  let(:attributes) do
    {
      date: Date.current,
      route_value: 200.00,
      fuel_cost: 50.00,
      maintenance_cost: 0,
      other_costs: 10.00,
      platform: 'shopee',
      notes: 'Dia chuvoso'
    }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_presence_of(:route_value) }

    it 'validates numericality' do
      trip_entry.route_value = -10
      expect(trip_entry).not_to be_valid
    end
  end

  describe '#save' do
    context 'with valid attributes' do
      it 'creates an Earning record' do
        expect { trip_entry.save }.to change(Earning, :count).by(1)

        earning = Earning.last
        expect(earning.amount).to eq(200.00)
        expect(earning.platform).to eq('shopee')
        expect(earning.notes).to eq('Dia chuvoso')
      end

      it 'creates Expense records for costs greater than zero' do
        expect { trip_entry.save }.to change(Expense, :count).by(2)

        expenses = Expense.where(date: trip_entry.date)
        expect(expenses.pluck(:category)).to include('fuel', 'other')
        expect(expenses.pluck(:category)).not_to include('maintenance')

        fuel_expense = expenses.find_by(category: 'fuel')
        expect(fuel_expense.amount).to eq(50.00)
      end
    end

    context 'when an error occurs during saving' do
      before do
        allow(Earning).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)
      end

      it 'does not create any record (Atomic Transaction)' do
        expect { trip_entry.save }.not_to change(Expense, :count)
      end

      it 'returns false' do
        expect(trip_entry.save).to be(false)
      end
    end
  end
end
