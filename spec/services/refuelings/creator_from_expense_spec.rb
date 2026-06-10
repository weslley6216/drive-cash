require 'rails_helper'

RSpec.describe Refuelings::CreatorFromExpense do
  let(:user) { create(:user) }
  let(:vehicle) { create(:vehicle, user: user) }
  let(:expense) { create(:expense, user: user, category: 'fuel', amount: 180.50) }

  before { vehicle }

  describe '.call' do
    it 'creates a Refueling linked to the expense when liters and odometer are present' do
      result = described_class.call(expense: expense, liters: '30,5', odometer_km: '48230', full_tank: true)

      expect(result).to be_a(Refueling)
      expect(result.persisted?).to be(true)
      expect(result.expense).to eq(expense)
      expect(result.vehicle).to eq(vehicle)
      expect(result.liters).to eq(30.5)
      expect(result.odometer_km).to eq(48_230)
      expect(result.total_amount).to eq(expense.amount)
      expect(result.full_tank).to be(true)
    end

    it 'copies the expense date and vendor' do
      expense.update(date: Date.new(2026, 5, 20), vendor: 'Posto Orense')

      result = described_class.call(expense: expense, liters: '30', odometer_km: '48000', full_tank: false)

      expect(result.date).to eq(Date.new(2026, 5, 20))
      expect(result.vendor).to eq('Posto Orense')
      expect(result.full_tank).to be(false)
    end

    it 'returns nil when liters is blank' do
      result = described_class.call(expense: expense, liters: '', odometer_km: '48230', full_tank: true)

      expect(result).to be_nil
      expect(Refueling.count).to eq(0)
    end

    it 'returns nil when odometer_km is blank' do
      result = described_class.call(expense: expense, liters: '30', odometer_km: nil, full_tank: true)

      expect(result).to be_nil
    end

    it 'returns nil when the user has no vehicle' do
      vehicle.destroy
      other_user = create(:user)
      other_expense = create(:expense, user: other_user, category: 'fuel')

      result = described_class.call(expense: other_expense, liters: '30', odometer_km: '48230', full_tank: true)

      expect(result).to be_nil
    end

    it 'returns nil when expense category is not fuel' do
      non_fuel = create(:expense, user: user, category: 'meals')

      result = described_class.call(expense: non_fuel, liters: '30', odometer_km: '48230', full_tank: true)

      expect(result).to be_nil
    end
  end
end
