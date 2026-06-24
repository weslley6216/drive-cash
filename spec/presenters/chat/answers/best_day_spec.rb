require 'rails_helper'

RSpec.describe Chat::Answers::BestDay do
  describe '#call' do
    it 'returns no_data when data is nil' do
      result = described_class.new(nil).call

      expect(result).to eq(I18n.t('chat.answer.no_data'))
    end

    it 'formats best day with date and amount' do
      data = { date: Date.new(2026, 6, 15), amount: 320.0 }

      result = described_class.new(data).call

      expect(result).to include('320,00')
      expect(result).to include('15 de junho')
    end
  end
end
