require 'rails_helper'

RSpec.describe Chat::Answers::PerKm do
  describe '#call' do
    it 'returns no_data when nil' do
      expect(described_class.new(nil).call).to eq(I18n.t('chat.answer.no_data'))
    end

    it 'formats per_km value' do
      result = described_class.new(1.75).call

      expect(result).to include('1,75')
    end
  end
end
