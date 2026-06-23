require 'rails_helper'

RSpec.describe Chat::Answers::CategorySpike do
  describe '#call' do
    it 'returns no_data when nil' do
      expect(described_class.new(nil).call).to eq(I18n.t('chat.answer.no_data'))
    end

    it 'formats category, amount and percent' do
      data = { category: 'Combustível', pct: 35.5, amount: 450.0 }

      result = described_class.new(data).call

      expect(result).to include('Combustível').and include('450,00').and include('36')
    end
  end
end
