require 'rails_helper'

RSpec.describe Expenses::InstallmentPlan do
  describe '#valid?' do
    it 'is valid with correct parameters' do
      plan = described_class.new(
        total_amount: 300,
        start_date: '2026-01-10',
        period: 'monthly',
        repetitions: 3
      )

      expect(plan.valid?).to be true
    end

    it 'is invalid with less than 2 repetitions' do
      plan = described_class.new(
        total_amount: 300,
        start_date: '2026-01-10',
        period: 'monthly',
        repetitions: 1
      )

      expect(plan.valid?).to be false
    end

    it 'is invalid with unknown period' do
      plan = described_class.new(
        total_amount: 300,
        start_date: '2026-01-10',
        period: 'invalid',
        repetitions: 3
      )

      expect(plan.valid?).to be false
    end
  end

  describe '#amounts' do
    it 'splits amount equally when divisible' do
      plan = described_class.new(
        total_amount: 300,
        start_date: '2026-01-10',
        period: 'monthly',
        repetitions: 3
      )

      expect(plan.amounts).to eq([BigDecimal('100'), BigDecimal('100'), BigDecimal('100')])
    end

    it 'distributes remainder across first installments' do
      plan = described_class.new(
        total_amount: 100,
        start_date: '2026-01-10',
        period: 'monthly',
        repetitions: 3
      )

      expect(plan.amounts.sum).to eq(BigDecimal('100'))
      expect(plan.amounts).to eq([BigDecimal('33.34'), BigDecimal('33.33'), BigDecimal('33.33')])
    end
  end

  describe '#dates' do
    it 'generates monthly dates' do
      plan = described_class.new(
        total_amount: 300,
        start_date: '2026-01-10',
        period: 'monthly',
        repetitions: 3
      )

      expect(plan.dates).to eq([
        Date.new(2026, 1, 10),
        Date.new(2026, 2, 10),
        Date.new(2026, 3, 10)
      ])
    end

    it 'generates weekly dates' do
      plan = described_class.new(
        total_amount: 300,
        start_date: '2026-01-10',
        period: 'weekly',
        repetitions: 3
      )

      expect(plan.dates).to eq([
        Date.new(2026, 1, 10),
        Date.new(2026, 1, 17),
        Date.new(2026, 1, 24)
      ])
    end

    it 'parses a non-string date via Date.parse' do
      plan = described_class.new(
        total_amount: 300,
        start_date: 20_260_110,
        period: 'monthly',
        repetitions: 3
      )

      expect(plan.dates.first).to eq(Date.new(2026, 1, 10))
    end
  end

  describe '#installment_attributes' do
    it 'returns merged attributes for given index' do
      plan = described_class.new(
        total_amount: 300,
        start_date: '2026-01-10',
        period: 'monthly',
        repetitions: 3
      )

      attrs = plan.installment_attributes(1)

      expect(attrs['amount']).to eq(BigDecimal('100'))
      expect(attrs['date']).to eq(Date.new(2026, 2, 10))
      expect(attrs['installment_number']).to eq(2)
      expect(attrs['installment_count']).to eq(3)
      expect(attrs['installment_series_id']).to eq(plan.series_id)
      expect(attrs['paid']).to be false
    end
  end
end
