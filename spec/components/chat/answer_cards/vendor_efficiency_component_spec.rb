require 'rails_helper'

RSpec.describe Chat::AnswerCards::VendorEfficiencyComponent, type: :component do
  let(:card) do
    { kind: 'vendor_efficiency', winner: 'Posto Orense', winner_kml: 11.5, runner_up: 'Geladão', runner_up_kml: 11.0, savings: 28 }
  end
  let(:html) { view_context.render(described_class.new(card: card)) }

  it 'compares the winner with the runner-up in one sentence' do
    expect(html).to include('O <strong>Posto Orense</strong> tem te rendido mais: 11,5 km/L contra 11,0 do Geladão.')
  end

  it 'draws a full green bar for the winner and a proportional gray bar for the runner-up' do
    expect(html).to include('<span class="text-slate-600 font-medium">Posto Orense</span><span class="text-slate-500 tabular-nums">11,5 km/L</span>')
    expect(html).to include('<span class="text-slate-600 font-medium">Geladão</span><span class="text-slate-500 tabular-nums">11,0 km/L</span>')
    expect(html).to include('width: 100%; background: #10b981')
    expect(html).to include('width: 96%; background: #94a3b8')
  end

  it 'estimates the monthly savings of filling up only at the winner' do
    expect(html).to include('<p class="text-xs text-slate-500">Economia estimada: <strong class="text-slate-700">~R$ 28/mês</strong> abastecendo só no Posto Orense.</p>')
  end

  context 'when there are no savings to estimate' do
    let(:card) { super().merge(savings: 0) }

    it 'hides the savings line' do
      expect(html).not_to include('Economia estimada')
    end
  end
end
