require 'rails_helper'

RSpec.describe Refuelings::TankCycles do
  let(:moves) do
    [
      { kind: :debit, date: Date.new(2026, 6, 6), amount: BigDecimal('-300'), description: 'Rota Shopee' },
      { kind: :credit, date: Date.new(2026, 6, 2), amount: BigDecimal('100'), full_tank: false,
        odometer_km: nil, liters: BigDecimal('17'), vendor: 'Posto Orense', price_per_liter: BigDecimal('5.88') },
      { kind: :debit, date: Date.new(2026, 5, 29), amount: BigDecimal('-50'), description: 'Rota Shopee' },
      { kind: :credit, date: Date.new(2026, 5, 28), amount: BigDecimal('250'), full_tank: true,
        odometer_km: 10_483, liters: BigDecimal('42'), vendor: 'Posto Geladão', price_per_liter: BigDecimal('5.95') },
      { kind: :debit, date: Date.new(2026, 5, 27), amount: BigDecimal('-60'), description: 'Rota Shopee' },
      { kind: :debit, date: Date.new(2026, 5, 20), amount: BigDecimal('-45'), description: 'Rota Shopee' },
      { kind: :credit, date: Date.new(2026, 5, 19), amount: BigDecimal('254'), full_tank: true,
        odometer_km: 10_000, liters: BigDecimal('43.4'), vendor: 'Posto Orense', price_per_liter: BigDecimal('5.85') }
    ]
  end
  let(:cycles) { described_class.call(moves: moves) }

  describe '.call' do
    it 'returns no cycle without moves' do
      expect(described_class.call(moves: [])).to eq([])
    end

    it 'opens a cycle on each full tank with the newest cycle first and flagged as current' do
      expect(cycles.map { |cycle| cycle.opener[:date] }).to eq([Date.new(2026, 5, 28), Date.new(2026, 5, 19)])
      expect(cycles.map(&:current)).to eq([true, false])
    end

    it 'keeps a partial refueling as a credit inside the open cycle' do
      expect(cycles.first.moves.map { |move| move[:date] })
        .to eq([Date.new(2026, 6, 6), Date.new(2026, 6, 2), Date.new(2026, 5, 29), Date.new(2026, 5, 28)])
    end

    it 'carries the running balance across cycles instead of resetting it on each full tank' do
      expect(cycles.last.moves.map { |move| move[:balance_after] }).to eq([149, 209, 254])
      expect(cycles.first.moves.map { |move| move[:balance_after] }).to eq([149, 449, 349, 399])
    end

    it 'closes each cycle on the running balance of its newest move' do
      expect(cycles.map(&:closing_balance)).to eq([149, 149])
    end

    it 'measures km per liter only on closed cycles opened by a full tank' do
      expect(cycles.last.km_per_liter).to eq(BigDecimal('11.5'))
      expect(cycles.first.km_per_liter).to be_nil
    end

    context 'when the oldest refueling did not fill the tank' do
      let(:moves) do
        [
          { kind: :credit, date: Date.new(2026, 5, 28), amount: BigDecimal('250'), full_tank: true,
            odometer_km: 10_483, liters: BigDecimal('42'), vendor: 'Posto Geladão', price_per_liter: BigDecimal('5.95') },
          { kind: :debit, date: Date.new(2026, 5, 20), amount: BigDecimal('-45'), description: 'Rota Shopee' },
          { kind: :credit, date: Date.new(2026, 5, 19), amount: BigDecimal('100'), full_tank: false,
            odometer_km: 10_000, liters: BigDecimal('17'), vendor: 'Posto Orense', price_per_liter: BigDecimal('5.88') }
        ]
      end

      it 'opens an initial cycle on it without km per liter' do
        expect(cycles.map { |cycle| cycle.opener[:date] }).to eq([Date.new(2026, 5, 28), Date.new(2026, 5, 19)])
        expect(cycles.last.km_per_liter).to be_nil
        expect(cycles.last.closing_balance).to eq(55)
      end
    end
  end
end
