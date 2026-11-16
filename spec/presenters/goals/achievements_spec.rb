require 'rails_helper'

RSpec.describe Goals::Achievements do
  describe '.present' do
    it 'labels a streak by its length on the phone and as a working sentence on the desktop' do
      raw = { type: :streak, days: 7 }

      result = described_class.present(raw)

      expect(result).to eq(type: :streak, short: 'Sequência 7 dias', long: 'Sequência de 7 dias trabalhando')
    end

    it 'labels a completed goal by its capitalized month and adds the rounded percent on the desktop' do
      raw = { type: :goal_completed, period_start: Date.new(2026, 4, 1), percent: BigDecimal('108.4') }

      result = described_class.present(raw)

      expect(result).to eq(type: :goal_completed, short: 'Meta de Abril', long: 'Meta de Abril batida (108%)')
    end

    it 'labels the best day with thousands separator and no cents and adds the abbreviated date on the desktop' do
      raw = { type: :best_day, value: BigDecimal('3000.70'), date: Date.new(2026, 5, 2) }

      result = described_class.present(raw)

      expect(result).to eq(type: :best_day, short: 'Melhor dia: R$ 3.001', long: 'Melhor dia: R$ 3.001 em 02/mai')
    end
  end
end
