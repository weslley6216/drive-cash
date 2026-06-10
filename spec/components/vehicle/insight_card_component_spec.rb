require 'rails_helper'

RSpec.describe Vehicle::InsightCardComponent, type: :component do
  describe '#view_template' do
    it 'renders title and description' do
      html = view_context.render(described_class.new(insight: {
        type: :cheapest_vendor,
        title: 'Posto Orense é o mais econômico',
        description: '11,5 km/L em média. Economia estimada: R$ 28/mês.'
      }))

      expect(html).to include('Posto Orense é o mais econômico')
      expect(html).to include('Economia estimada: R$ 28/mês')
    end

    it 'uses blue tones' do
      html = view_context.render(described_class.new(insight: { type: :cheapest_vendor, title: 't', description: 'd' }))

      expect(html).to include('bg-blue-50')
      expect(html).to include('border-blue-200')
    end
  end
end
