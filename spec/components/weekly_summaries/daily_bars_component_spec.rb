require 'rails_helper'

RSpec.describe WeeklySummaries::DailyBarsComponent, type: :component do
  let(:week) { Date.new(2026, 7, 6)..Date.new(2026, 7, 12) }

  it 'labels the bars from monday to sunday' do
    html = view_context.render(described_class.new(week: week, daily_profits: [0, 0, 0, 0, 0, 0, 0], best_day_index: nil))

    labels = html.scan(/<span class="text-\[10px\][^"]*">([^<]+)<\/span>/).flatten

    expect(labels).to eq(%w[seg ter qua qui sex sáb dom])
  end

  it 'highlights the best day and scales bars to it' do
    daily_profits = [182, 240, 0, 156, 268, 141, 0]

    html = view_context.render(described_class.new(week: week, daily_profits: daily_profits, best_day_index: 4))

    expect(html).to include('bg-blue-600')
    expect(html).to include('height: 76.0px')
    expect(html).to include('bg-blue-200')
    expect(html).to include('height: 68.1px')
    expect(html).to include('bg-slate-100')
    expect(html).to include('height: 4px')
  end

  it 'stubs a day with negative profit' do
    daily_profits = [-50, 0, 0, 0, 0, 0, 0]

    html = view_context.render(described_class.new(week: week, daily_profits: daily_profits, best_day_index: nil))

    expect(html).to include('bg-slate-100')
    expect(html).to include('height: 4px')
  end

  it 'announces the best day' do
    daily_profits = [182, 240, 0, 156, 268, 141, 0]

    html = view_context.render(described_class.new(week: week, daily_profits: daily_profits, best_day_index: 4))

    expect(html).to include('Sexta foi o melhor dia:')
    expect(html).to include('R$ 268,00')
  end

  it 'omits the best day sentence when no day is profitable' do
    daily_profits = [0, 0, 0, 0, 0, 0, 0]

    html = view_context.render(described_class.new(week: week, daily_profits: daily_profits, best_day_index: nil))

    expect(html).not_to include('melhor dia')
  end
end
