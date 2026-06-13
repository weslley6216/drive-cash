require 'rails_helper'

RSpec.describe Vehicles::InsightCardComponent, type: :component do
  let(:insight) do
    {
      type: :cheapest_vendor,
      winner: 'Posto Orense',
      winner_kml: 11.5,
      runner_up: 'Posto Geladão',
      runner_up_kml: 11.0,
      savings: 28
    }
  end

  describe '#view_template' do
    it 'builds the title from the winning vendor' do
      html = view_context.render(described_class.new(insight: insight))

      expect(html).to include('Posto Orense é o mais econômico')
    end

    it 'builds the body with formatted efficiency and short currency savings' do
      html = view_context.render(described_class.new(insight: insight))

      expect(html).to include('11,5 km/L')
      expect(html).to include('11,0 do Posto Geladão')
      expect(html).to include('Economia estimada: R$ 28/mês')
    end

    it 'uses blue tones' do
      html = view_context.render(described_class.new(insight: insight))

      expect(html).to include('bg-blue-50')
      expect(html).to include('border-blue-200')
    end
  end
end
