require 'rails_helper'

RSpec.describe Exports::PeriodRange do
  let(:today) { Date.new(2026, 6, 15) }

  describe 'derivation by kind' do
    it 'resolves this_month to the current month' do
      range = described_class.new(kind: 'this_month', today: today)

      expect(range.period_start).to eq(Date.new(2026, 6, 1))
      expect(range.period_end).to eq(Date.new(2026, 6, 30))
    end

    it 'resolves last_month to the previous month' do
      range = described_class.new(kind: 'last_month', today: today)

      expect(range.period_start).to eq(Date.new(2026, 5, 1))
      expect(range.period_end).to eq(Date.new(2026, 5, 31))
    end

    it 'resolves year to the current calendar year' do
      range = described_class.new(kind: 'year', today: today)

      expect(range.period_start).to eq(Date.new(2026, 1, 1))
      expect(range.period_end).to eq(Date.new(2026, 12, 31))
    end

    it 'returns the custom dates when kind is custom' do
      range = described_class.new(
        kind:         'custom',
        today:        today,
        custom_start: Date.new(2026, 3, 1),
        custom_end:   Date.new(2026, 4, 30)
      )

      expect(range.period_start).to eq(Date.new(2026, 3, 1))
      expect(range.period_end).to eq(Date.new(2026, 4, 30))
    end
  end
end
