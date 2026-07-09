require 'rails_helper'

RSpec.describe Refuelings::CreatorFromExpense do
  let(:user) { create(:user) }
  let(:vehicle) { create(:vehicle, user: user) }
  let(:expense) { create(:expense, user: user, category: 'fuel', amount: 180.50) }

  before { vehicle }

  describe '.call' do
    it 'creates a Refueling linked to the expense when liters and odometer are present' do
      result = described_class.call(expense: expense, liters: '30,5', odometer_km: '48230', full_tank: true)

      expect(result.success?).to be(true)
      expect(result.refueling).to be_persisted
      expect(result.refueling.expense).to eq(expense)
      expect(result.refueling.liters).to eq(30.5)
      expect(result.refueling.odometer_km).to eq(48_230)
      expect(result.refueling.total_amount).to eq(expense.amount)
    end

    it 'copies the expense date and vendor' do
      expense.update(date: Date.new(2026, 5, 20), vendor: 'Posto Orense')

      result = described_class.call(expense: expense, liters: '30', odometer_km: '48000', full_tank: false)

      expect(result.refueling.date).to eq(Date.new(2026, 5, 20))
      expect(result.refueling.vendor).to eq('Posto Orense')
      expect(result.refueling.full_tank).to be(false)
    end

    it 'normalizes liters with pt-BR separators through the model concern' do
      result = described_class.call(expense: expense, liters: '1.234,56', odometer_km: '48230', full_tank: true)

      expect(result.refueling.liters).to eq(BigDecimal('1234.56'))
    end

    it 'skips without error when liters is blank' do
      result = described_class.call(expense: expense, liters: '', odometer_km: '48230', full_tank: true)

      expect(result.success?).to be(true)
      expect(result.refueling).to be_nil
      expect(Refueling.count).to eq(0)
    end

    it 'skips without error when odometer_km is blank' do
      result = described_class.call(expense: expense, liters: '30', odometer_km: nil, full_tank: true)

      expect(result.success?).to be(true)
      expect(result.refueling).to be_nil
    end

    it 'skips when the user has no vehicle' do
      vehicle.destroy
      other_user = create(:user)
      other_expense = create(:expense, user: other_user, category: 'fuel')

      result = described_class.call(expense: other_expense, liters: '30', odometer_km: '48230', full_tank: true)

      expect(result.success?).to be(true)
      expect(result.refueling).to be_nil
    end

    it 'skips when the expense category is not fuel' do
      non_fuel = create(:expense, user: user, category: 'meals')

      result = described_class.call(expense: non_fuel, liters: '30', odometer_km: '48230', full_tank: true)

      expect(result.success?).to be(true)
      expect(result.refueling).to be_nil
    end

    it 'returns failure and persists nothing when the refueling is invalid' do
      result = described_class.call(expense: expense, liters: '0', odometer_km: '48230', full_tank: true)

      expect(result.success?).to be(false)
      expect(result.refueling.errors[:liters]).to be_present
      expect(Refueling.count).to eq(0)
    end

    it 'advances the vehicle odometer when the created refueling km is greater' do
      vehicle.update!(odometer_km: 48_000, odometer_updated_at: Time.zone.local(2026, 6, 1))
      expense.update!(date: Date.new(2026, 6, 22))

      described_class.call(expense: expense, liters: '30', odometer_km: '48230', full_tank: true)

      expect(vehicle.reload.odometer_km).to eq(48_230)
      expect(vehicle.odometer_updated_at.to_date).to eq(Date.new(2026, 6, 22))
    end

    it 'does not recede the vehicle odometer when the created refueling km is smaller' do
      vehicle.update!(odometer_km: 50_000, odometer_updated_at: Time.zone.local(2026, 6, 1))

      described_class.call(expense: expense, liters: '30', odometer_km: '48230', full_tank: true)

      expect(vehicle.reload.odometer_km).to eq(50_000)
    end
  end
end
