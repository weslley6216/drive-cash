require 'rails_helper'

RSpec.describe Chat::AnswerCards::AnswerStatComponent, type: :component do
  it 'draws the icon in a tinted circle, the label and the value in the tone color' do
    html = view_context.render(
      described_class.new(label: 'Receitas', value: '+R$ 1.680,00', icon: PhlexIcons::Lucide::ArrowUpRight, tone: :emerald)
    )

    expect(html).to include(described_class::ROW)
    expect(html).to include('rounded-full flex items-center justify-center flex-shrink-0 bg-emerald-100 text-emerald-600"><svg')
    expect(html).to include('<p class="text-sm text-slate-600 leading-tight">Receitas</p>')
    expect(html).to include('<p class="text-sm font-semibold tabular-nums whitespace-nowrap text-emerald-700">+R$ 1.680,00</p>')
  end

  it 'adds the detail under the label when given' do
    html = view_context.render(
      described_class.new(label: 'Melhor dia', value: 'R$ 320,00', icon: PhlexIcons::Lucide::Trophy, tone: :violet, detail: 'Qui, 12/11')
    )

    expect(html).to include('<p class="text-xs text-slate-400 leading-tight mt-0.5 truncate">Qui, 12/11</p>')
    expect(html).to include('bg-violet-100 text-violet-600')
    expect(html).to include('text-slate-800">R$ 320,00</p>')
  end

  it 'falls back to slate for an unknown tone' do
    html = view_context.render(described_class.new(label: 'Outro', value: 'R$ 1,00', icon: PhlexIcons::Lucide::Trophy, tone: :amber))

    expect(html).to include('bg-slate-100 text-slate-500')
    expect(html).not_to include('text-xs text-slate-400')
  end
end
