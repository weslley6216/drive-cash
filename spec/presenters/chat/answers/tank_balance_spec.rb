require 'rails_helper'

RSpec.describe Chat::Answers::TankBalance do
  describe '#call' do
    it 'returns no_data when data is nil' do
      result = described_class.new(nil).call

      expect(result).to eq(I18n.t('chat.answer.no_data'))
    end

    it 'returns no_data when balance is zero' do
      result = described_class.new({ balance: 0, full: 100 }).call

      expect(result).to eq(I18n.t('chat.answer.no_data'))
    end

    it 'formats balance and percentage' do
      data = { balance: 40.0, full: 80.0 }

      result = described_class.new(data).call

      expect(result).to include('40,00')
      expect(result).to include('50')
    end
  end
end
