require 'rails_helper'

RSpec.describe Dashboard::Insights::Presenters do
  describe '.present' do
    it 'renders category_share with the share in the title and the period amount in the description' do
      raw = {
        type:    'category_share',
        payload: { category_id: 'fuel', category: 'Combustível', percent: 52.7, amount: 220.0, year: 2025, month: 6 }
      }

      result = described_class.present(raw)

      expect(result[:type]).to eq('category_share')
      expect(result[:title]).to eq('Combustível leva 52,7% dos seus gastos')
      expect(result[:description]).to eq('Foram R$ 220,00 no mês. É a categoria que mais pesa no seu lucro por km.')
      expect(result[:link]).to eq(label: 'Ver lançamentos →', params: { filter: 'fuel', year: 2025, month: 6 })
    end

    it 'uses the annual period wording when no month is given' do
      raw = {
        type:    'category_share',
        payload: { category_id: 'fuel', category: 'Combustível', percent: 52.7, amount: 220.0, year: 2025, month: nil }
      }

      result = described_class.present(raw)

      expect(result[:description]).to include('no ano')
      expect(result[:link][:params]).to eq(filter: 'fuel', year: 2025, month: nil)
    end
  end

  describe 'producer/presenter coverage' do
    it 'defines a presenter for every insight rule emitted by InsightsService' do
      Dashboard::InsightsService::INSIGHT_RULES.each do |rule|
        expect(described_class.const_defined?(rule.name.demodulize)).to be(true)
      end
    end
  end
end
