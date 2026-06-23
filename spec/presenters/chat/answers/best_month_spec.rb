require 'rails_helper'

RSpec.describe Chat::Answers::BestMonth do
  describe '#call' do
    it 'returns no_data when nil' do
      expect(described_class.new(nil).call).to eq(I18n.t('chat.answer.no_data'))
    end

    it 'formats month, year and profit' do
      data = { month: 3, year: 2026, profit: 4200.0 }

      result = described_class.new(data).call

      expect(result).to include('3').and include('2026').and include('4.200,00')
    end
  end
end
