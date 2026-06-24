require 'rails_helper'

RSpec.describe Chat::Answers::PlatformBreakdown do
  describe '#call' do
    it 'returns no_data when blank' do
      expect(described_class.new([]).call).to eq(I18n.t('chat.answer.no_data'))
    end

    it 'formats each platform with amount and percent' do
      data = [{ label: 'Uber', amount: 800.0, percent: 80.0 }, { label: 'iFood', amount: 200.0, percent: 20.0 }]

      result = described_class.new(data).call

      expect(result).to include('Uber').and include('800,00').and include('80%')
    end
  end
end
