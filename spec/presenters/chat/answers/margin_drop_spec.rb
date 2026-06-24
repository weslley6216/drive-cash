require 'rails_helper'

RSpec.describe Chat::Answers::MarginDrop do
  describe '#call' do
    it 'returns no_data when nil' do
      expect(described_class.new(nil).call).to eq(I18n.t('chat.answer.no_data'))
    end

    it 'formats pp and current margin' do
      data = { pp: 5.0, current_margin: 42.0 }

      result = described_class.new(data).call

      expect(result).to include('5').and include('42')
    end
  end
end
