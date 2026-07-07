require 'rails_helper'

RSpec.describe Exports::Builder do
  let(:user) { create(:user) }
  let(:vehicle) { create(:vehicle, user: user) }
  let(:period_start) { Date.new(2026, 1, 1) }
  let(:period_end) { Date.new(2026, 12, 31) }

  def build_export(includes:)
    create(:export,
           user:         user,
           period_kind:  'year',
           period_start: period_start,
           period_end:   period_end,
           includes:     includes)
  end

  describe '.call' do
    it 'aggregates earnings inside the period when toggle is on' do
      create(:earning, user: user, date: Date.new(2026, 3, 5), amount: 200.00, platform: 'uber')
      create(:earning, user: user, date: Date.new(2025, 12, 31), amount: 999.00, platform: 'uber')
      export = build_export(includes: { 'earnings' => true, 'expenses' => false, 'refuelings' => false, 'maintenances' => false })

      payload = described_class.call(export: export)

      expect(payload.earnings.size).to eq(1)
      expect(payload.earnings.first[:amount]).to eq(BigDecimal('200.00'))
      expect(payload.totals[:earnings]).to eq(BigDecimal('200.00'))
      expect(payload.totals[:count]).to eq(1)
    end

    it 'aggregates expenses inside the period when toggle is on' do
      create(:expense, user: user, date: Date.new(2026, 2, 10), amount: 50.00, category: 'fuel')
      export = build_export(includes: { 'earnings' => false, 'expenses' => true, 'refuelings' => false, 'maintenances' => false })

      payload = described_class.call(export: export)

      expect(payload.expenses.size).to eq(1)
      expect(payload.totals[:expenses]).to eq(BigDecimal('50.00'))
    end

    it 'computes profit as earnings minus expenses' do
      create(:earning, user: user, date: Date.new(2026, 3, 1), amount: 300.00)
      create(:expense, user: user, date: Date.new(2026, 3, 2), amount: 100.00, category: 'fuel')
      export = build_export(includes: { 'earnings' => true, 'expenses' => true, 'refuelings' => false, 'maintenances' => false })

      payload = described_class.call(export: export)

      expect(payload.totals[:profit]).to eq(BigDecimal('200.00'))
    end

    it 'includes refuelings of the user vehicle inside period' do
      create(:refueling, vehicle: vehicle, date: Date.new(2026, 4, 1), total_amount: 180.00, liters: 30.0)
      export = build_export(includes: { 'earnings' => false, 'expenses' => false, 'refuelings' => true, 'maintenances' => false })

      payload = described_class.call(export: export)

      expect(payload.refuelings.size).to eq(1)
      expect(payload.refuelings.first[:total_amount]).to eq(BigDecimal('180.00'))
    end

    it 'includes maintenances of the user vehicle when toggle is on' do
      create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 30_000, interval_km: 5_000)
      export = build_export(includes: { 'earnings' => false, 'expenses' => false, 'refuelings' => false, 'maintenances' => true })

      payload = described_class.call(export: export)

      expect(payload.maintenances.size).to eq(1)
    end

    it 'returns empty sections when toggles are off' do
      create(:earning, user: user, date: Date.new(2026, 3, 5), amount: 200.00)
      export = build_export(includes: { 'earnings' => false, 'expenses' => false, 'refuelings' => false, 'maintenances' => false })

      payload = described_class.call(export: export)

      expect(payload.earnings).to be_empty
      expect(payload.totals[:earnings]).to eq(0)
      expect(payload.totals[:count]).to eq(0)
    end

    it 'scopes everything to the export user' do
      other = create(:user)
      create(:earning, user: other, date: Date.new(2026, 3, 5), amount: 999.00)
      export = build_export(includes: { 'earnings' => true, 'expenses' => false, 'refuelings' => false, 'maintenances' => false })

      payload = described_class.call(export: export)

      expect(payload.earnings).to be_empty
    end

    it 'filters records to the derived period_kind window' do
      travel_to Date.new(2026, 6, 15) do
        create(:earning, user: user, date: Date.new(2026, 6, 10), amount: 100)
        create(:earning, user: user, date: Date.new(2026, 5, 10), amount: 999)

        export = create(:export, user: user, period_kind: 'this_month', period_start: nil, period_end: nil, includes: { 'earnings' => true, 'expenses' => false, 'refuelings' => false, 'maintenances' => false })

        payload = described_class.call(export: export)

        expect(payload.earnings.map { |row| row[:amount] }).to eq([BigDecimal('100')])
      end
    end

    it 'returns an empty payload when the period bounds are unresolved' do
      export = build(:export, user: user, period_kind: nil, period_start: nil, period_end: nil)

      payload = described_class.call(export: export)

      expect(payload.earnings).to be_empty
      expect(payload.expenses).to be_empty
      expect(payload.totals[:count]).to eq(0)
    end

    it 'excludes unpaid expenses from totals but keeps them in the rows' do
      create(:expense, user: user, date: Date.new(2026, 2, 10), amount: 50.00, category: 'fuel', paid: true)
      create(:expense, user: user, date: Date.new(2026, 2, 11), amount: 30.00, category: 'fuel', paid: false)
      export = build_export(includes: { 'earnings' => false, 'expenses' => true, 'refuelings' => false, 'maintenances' => false })

      payload = described_class.call(export: export)

      expect(payload.expenses.size).to eq(2)
      expect(payload.totals[:expenses]).to eq(BigDecimal('50.00'))
    end
  end
end
