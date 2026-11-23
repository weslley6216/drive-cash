require 'rails_helper'

RSpec.describe WeeklySummaries::DailyBarsComponent, type: :component do
  let(:week) { Calendars::Week.containing(Date.new(2026, 7, 6)) }

  it 'labels the bars from monday to sunday' do
    html = view_context.render(described_class.new(week: week, daily_profits: [0, 0, 0, 0, 0, 0, 0], best_day_index: nil))

    labels = html.scan(/<span class="text-\[10px\][^"]*">([^<]+)<\/span>/).flatten

    expect(labels).to eq(%w[seg ter qua qui sex sáb dom])
  end

  it 'highlights the best day and scales bars as a share of the track' do
    html = view_context.render(described_class.new(week: week, daily_profits: [182, 240, 0, 156, 268, 141, 0], best_day_index: 4))

    expect(html).to include('bg-blue-600')
    expect(html).to include('height: 100.0%')
    expect(html).to include('bg-blue-200')
    expect(html).to include('height: 89.6%')
    expect(html).to include('bg-slate-100')
    expect(html).to include('height: 4px')
  end

  it 'grows the track from 96px on the phone to 150px on the desktop' do
    html = view_context.render(described_class.new(week: week, daily_profits: [0, 0, 0, 0, 0, 0, 0], best_day_index: nil))

    expect(html).to include('h-[96px] lg:h-[150px]')
  end

  it 'stubs a day with negative profit' do
    html = view_context.render(described_class.new(week: week, daily_profits: [-50, 0, 0, 0, 0, 0, 0], best_day_index: nil))

    expect(html).to include('bg-slate-100')
    expect(html).to include('height: 4px')
  end

  it 'announces the best day and the days without records' do
    html = view_context.render(described_class.new(week: week, daily_profits: [182, 240, 0, 156, 268, 141, 0], best_day_index: 4,
                                                   empty_days: [Date.new(2026, 7, 8), Date.new(2026, 7, 12)]))

    expect(html).to include('Sexta foi o melhor dia:')
    expect(html).to include('R$ 268,00')
    expect(html).to include('Quarta e domingo sem lançamentos.')
  end

  it 'joins three days without records in a sentence' do
    html = view_context.render(described_class.new(week: week, daily_profits: [0, 0, 0, 0, 0, 0, 0], best_day_index: nil,
                                                   empty_days: [Date.new(2026, 7, 7), Date.new(2026, 7, 9), Date.new(2026, 7, 11)]))

    expect(html).to include('Terça, quinta e sábado sem lançamentos.')
  end

  it 'omits the best day sentence when no day is profitable' do
    html = view_context.render(described_class.new(week: week, daily_profits: [0, 0, 0, 0, 0, 0, 0], best_day_index: nil))

    expect(html).not_to include('melhor dia')
  end

  it 'says the week has no records instead of the day sentences on a blank week' do
    html = view_context.render(described_class.new(week: week, daily_profits: [0, 0, 0, 0, 0, 0, 0], best_day_index: nil,
                                                   empty_days: week.range.to_a, blank_week: true))

    expect(html).to include('Nenhum lançamento nesta semana.')
    expect(html).not_to include('sem lançamentos')
  end
end
