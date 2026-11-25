require 'rails_helper'

RSpec.describe Chat::Answers::Summary do
  describe '#call' do
    it 'returns the month numbers as a card payload with the best day as an ISO date' do
      data = {
        year: 2026, month: 11, profit: 1240.0, earnings: 1680.0, expenses: 440.0, profit_change: 12.0,
        best_day: { date: Date.new(2026, 11, 12), amount: 320.0 }
      }

      result = described_class.new(data).call

      expect(result.to_h).to eq(
        year: 2026, month: 11, profit: 1240.0, earnings: 1680.0, expenses: 440.0, profit_change: 12.0,
        best_day_on: '2026-11-12', best_day_amount: 320.0
      )
    end

    it 'leaves the best day empty in a yearly summary' do
      data = { year: 2026, month: nil, profit: 1240.0, earnings: 1680.0, expenses: 440.0, profit_change: nil, best_day: nil }

      result = described_class.new(data).call

      expect(result.best_day_on).to be_nil
      expect(result.best_day_amount).to be_nil
    end

    it 'returns no_data when data is nil' do
      result = described_class.new(nil).call

      expect(result).to eq(I18n.t('chat.answer.no_data'))
    end
  end
end
