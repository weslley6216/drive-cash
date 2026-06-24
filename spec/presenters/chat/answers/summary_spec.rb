require 'rails_helper'

RSpec.describe Chat::Answers::Summary do
  describe '#call' do
    it 'formats profit, earnings and expenses' do
      data = { profit: 500.0, earnings: 1000.0, expenses: 500.0 }

      result = described_class.new(data).call

      expect(result).to include('500,00')
      expect(result).to include('1.000,00').or include('1000,00')
    end

    it 'includes margin when present' do
      data = { profit: 200.0, earnings: 400.0, expenses: 200.0, margin: 50.0 }

      result = described_class.new(data).call

      expect(result).to include('50')
    end

    it 'includes per_km when present' do
      data = { profit: 200.0, earnings: 400.0, expenses: 200.0, per_km: 2.5 }

      result = described_class.new(data).call

      expect(result).to include('2,50')
    end

    it 'returns no_data when data is nil' do
      result = described_class.new(nil).call

      expect(result).to eq(I18n.t('chat.answer.no_data'))
    end
  end
end
