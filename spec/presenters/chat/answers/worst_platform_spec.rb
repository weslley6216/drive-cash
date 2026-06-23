require 'rails_helper'

RSpec.describe Chat::Answers::WorstPlatform do
  describe '#call' do
    it 'returns no_data when nil' do
      expect(described_class.new(nil).call).to eq(I18n.t('chat.answer.no_data'))
    end

    it 'formats platform and per_trip' do
      data = { platform: 'Shopee', per_trip: 8.5 }

      result = described_class.new(data).call

      expect(result).to include('Shopee').and include('8,50')
    end
  end
end
