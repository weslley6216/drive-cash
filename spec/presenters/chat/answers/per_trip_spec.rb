require 'rails_helper'

RSpec.describe Chat::Answers::PerTrip do
  describe '#call' do
    it 'returns no_data when nil' do
      expect(described_class.new(nil).call).to eq(I18n.t('chat.answer.no_data'))
    end

    it 'returns no_data when zero' do
      expect(described_class.new(0).call).to eq(I18n.t('chat.answer.no_data'))
    end

    it 'formats per_trip value' do
      result = described_class.new(12.5).call

      expect(result).to include('12,50')
    end
  end
end
