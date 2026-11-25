require 'rails_helper'

RSpec.describe Chat::AnswerCards::AnswerStatComponent, type: :component do
  it 'puts the label beside the value on a phone and above it from the small breakpoint' do
    html = view_context.render(described_class.new(label: 'Receitas', value: '+R$ 1.680,00', tone: :emerald))

    expect(html).to include(described_class::ROW)
    expect(html).to include('<p class="text-[10px] font-medium text-slate-400 uppercase tracking-wide">Receitas</p>')
    expect(html).to include('<p class="text-sm font-bold tabular-nums whitespace-nowrap text-emerald-700">+R$ 1.680,00</p>')
  end

  it 'paints the value red for the red tone' do
    html = view_context.render(described_class.new(label: 'Despesas', value: '−R$ 440,00', tone: :red))

    expect(html).to include('text-red-700')
  end

  it 'falls back to slate without a tone' do
    html = view_context.render(described_class.new(label: 'Melhor dia', value: 'Qui · R$ 320'))

    expect(html).to include('<p class="text-sm font-bold tabular-nums whitespace-nowrap text-slate-800">Qui · R$ 320</p>')
  end
end
