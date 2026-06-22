require 'rails_helper'

RSpec.describe Refuelings::Moves do
  let(:user) { create(:user) }
  let(:vehicle) { create(:vehicle, user: user) }

  describe '.call' do
    it 'returns an empty array when user has no vehicle' do
      user_without_vehicle = create(:user)

      result = described_class.call(user: user_without_vehicle)

      expect(result).to eq([])
    end

    it 'returns an empty array when vehicle has no refuelings' do
      vehicle

      result = described_class.call(user: user)

      expect(result).to eq([])
    end

    it 'returns credits for each refueling with kind credit' do
      create(:refueling, vehicle: vehicle, vendor: 'Posto Orense',
                         date: Date.new(2026, 6, 1), total_amount: 180, liters: 32.5)

      result = described_class.call(user: user)

      expect(result.size).to eq(1)
      expect(result.first[:kind]).to eq(:credit)
      expect(result.first[:vendor]).to eq('Posto Orense')
      expect(result.first[:amount]).to eq(180)
    end

    it 'returns debits for fuel expenses without refueling after anchor date' do
      create(:refueling, vehicle: vehicle, date: Date.new(2026, 6, 1))
      create(:expense, user: user, category: 'fuel', amount: 45,
                       date: Date.new(2026, 6, 5), description: 'Rota IFood')

      result = described_class.call(user: user)

      debit = result.find { |move| move[:kind] == :debit }
      expect(debit[:amount]).to eq(-45)
      expect(debit[:description]).to eq('Rota IFood')
    end

    it 'ignores fuel expenses dated before the first refueling (anchor)' do
      create(:refueling, vehicle: vehicle, date: Date.new(2026, 6, 10))
      create(:expense, user: user, category: 'fuel', amount: 40, date: Date.new(2026, 6, 9))

      result = described_class.call(user: user)

      expect(result.none? { |move| move[:kind] == :debit }).to be(true)
    end

    it 'ignores fuel expenses already linked to a refueling' do
      refueling = create(:refueling, vehicle: vehicle, date: Date.new(2026, 6, 1))
      create(:expense, user: user, category: 'fuel', amount: 180,
                       date: Date.new(2026, 6, 1), refueling: refueling)

      result = described_class.call(user: user)

      expect(result.count { |move| move[:kind] == :debit }).to eq(0)
    end

    it 'ignores non-fuel expenses' do
      create(:refueling, vehicle: vehicle, date: Date.new(2026, 6, 1))
      create(:expense, user: user, category: 'maintenance', amount: 200,
                       date: Date.new(2026, 6, 5))

      result = described_class.call(user: user)

      expect(result.count { |move| move[:kind] == :debit }).to eq(0)
    end

    it 'orders moves chronologically descending' do
      create(:refueling, vehicle: vehicle, date: Date.new(2026, 6, 1))
      create(:refueling, vehicle: vehicle, date: Date.new(2026, 6, 15))

      result = described_class.call(user: user)

      expect(result.map { |move| move[:date] }).to eq([Date.new(2026, 6, 15), Date.new(2026, 6, 1)])
    end

    it 'scopes credits to the user vehicle (does not leak from other users)' do
      vehicle
      other_vehicle = create(:vehicle)
      create(:refueling, vehicle: other_vehicle, vendor: 'Posto Rival')
      create(:refueling, vehicle: vehicle, vendor: 'Posto Orense')

      result = described_class.call(user: user)

      expect(result.map { |move| move[:vendor] }).to all(eq('Posto Orense'))
    end
  end
end
