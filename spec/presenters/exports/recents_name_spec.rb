require 'rails_helper'

RSpec.describe Exports::RecentsName do
  describe '#call' do
    it 'names this_month with month and year' do
      export = build(:export, period_kind: 'this_month', period_start: Date.new(2026, 5, 1), period_end: Date.new(2026, 5, 31))

      expect(described_class.new(export).call).to eq(I18n.t('exports.recents_name.this_month', month: 'maio', year: 2026))
    end

    it 'names last_month with previous month and year' do
      export = build(:export, period_kind: 'last_month', period_start: Date.new(2026, 4, 1), period_end: Date.new(2026, 4, 30))

      expect(described_class.new(export).call).to eq(I18n.t('exports.recents_name.last_month', month: 'abril', year: 2026))
    end

    it 'names year with the year only' do
      export = build(:export, period_kind: 'year', period_start: Date.new(2026, 1, 1), period_end: Date.new(2026, 12, 31))

      expect(described_class.new(export).call).to eq(I18n.t('exports.recents_name.year', year: 2026))
    end

    it 'names custom with the formatted range' do
      export = build(:export, period_kind: 'custom', period_start: Date.new(2026, 3, 1), period_end: Date.new(2026, 4, 30))

      expect(described_class.new(export).call).to eq(I18n.t('exports.recents_name.custom', start: '01/03/2026', end: '30/04/2026'))
    end

    it 'returns an empty string when the period is unresolved' do
      export = build(:export, period_kind: 'x', period_start: nil, period_end: nil)

      expect(described_class.new(export).call).to eq('')
    end
  end
end
