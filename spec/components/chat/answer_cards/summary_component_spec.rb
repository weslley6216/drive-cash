require 'rails_helper'

RSpec.describe Chat::AnswerCards::SummaryComponent, type: :component do
  let(:card) do
    {
      kind: 'summary', year: 2026, month: 11, profit: 1240.0, earnings: 1680.0, expenses: 440.0,
      profit_change: 12.0, best_day_on: '2026-11-12', best_day_amount: 320.0
    }
  end
  let(:html) { view_context.render(described_class.new(card: card)) }

  before { travel_to Date.new(2026, 11, 25) }

  it 'tells the month profit with the change against the previous month' do
    expect(html).to include('Esse mês você lucrou <strong>R$ 1.240,00</strong> — 12% acima do mês anterior.')
  end

  it 'lists income, expenses and the best day as rows in their tones' do
    expect(html).to include(described_class::STATS)
    expect(html).to include('text-emerald-700">+R$ 1.680,00</p>')
    expect(html).to include('text-red-700">−R$ 440,00</p>')
    expect(html).to include('Melhor dia').and include('Qui, 12/11').and include('text-slate-800">R$ 320,00</p>')
    expect(html.scan(Chat::AnswerCards::AnswerStatComponent::ROW).size).to eq(3)
  end

  it 'points the income arrow up and the expenses arrow down' do
    arrow_up = view_context.render(PhlexIcons::Lucide::ArrowUpRight.new(class: 'w-4 h-4'))
    arrow_down = view_context.render(PhlexIcons::Lucide::ArrowDownRight.new(class: 'w-4 h-4'))

    expect(html).to include("bg-emerald-100 text-emerald-600\">#{arrow_up}")
    expect(html).to include("bg-red-100 text-red-600\">#{arrow_down}")
  end

  context 'when the profit fell against the previous month' do
    let(:card) { super().merge(profit_change: -8.0) }

    it 'says it is below the previous month' do
      expect(html).to include('— 8% abaixo do mês anterior.')
    end
  end

  context 'when the month is not the current one' do
    let(:card) { super().merge(month: 6) }

    it 'names the month' do
      expect(html).to include('Em junho você lucrou')
    end
  end

  context 'when the summary covers the current year' do
    let(:card) { super().merge(month: nil, profit_change: nil, best_day_on: nil, best_day_amount: nil) }

    it 'tells the year profit without comparison or best day' do
      expect(html).to include('Esse ano você lucrou <strong>R$ 1.240,00</strong>.')
      expect(html).not_to include('Melhor dia')
      expect(html.scan(Chat::AnswerCards::AnswerStatComponent::ROW).size).to eq(2)
    end
  end

  context 'when the summary covers a past year' do
    let(:card) { super().merge(year: 2025, month: nil, profit_change: nil, best_day_on: nil, best_day_amount: nil) }

    it 'names the year' do
      expect(html).to include('Em 2025 você lucrou')
    end
  end
end
