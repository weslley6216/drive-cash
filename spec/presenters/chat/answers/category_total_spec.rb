require 'rails_helper'

RSpec.describe Chat::Answers::CategoryTotal do
  describe '#call' do
    it 'tells the total spent with the category label' do
      result = described_class.new({ category: 'fuel', total: 320.0 }).call

      expect(result).to include('Combustível').and include("R$\u00A0320,00")
    end

    it 'returns no_data when data is nil' do
      result = described_class.new(nil).call

      expect(result).to eq(I18n.t('chat.answer.no_data'))
    end
  end
end
