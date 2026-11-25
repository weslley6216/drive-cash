require 'rails_helper'

RSpec.describe WeeklySummaries::DailyBarsComponent, type: :component do
  let(:week) { Calendars::Week.containing(Date.new(2026, 7, 6)) }
  let(:today) { Date.new(2026, 7, 20) }
  let(:profits) { [182, 240, 0, 156, 268, 141, 0] }
  let(:best_day_index) { 4 }
  let(:empty_days) { [] }
  let(:blank_week) { false }
  let(:days) do
    week.range.zip(profits).map do |date, profit|
      WeeklySummaries::Builder::Day.new(date: date, profit: profit, earnings: profit.zero? ? 0 : profit + 100,
                                        expenses: profit.zero? ? 0 : 100, trips: profit.zero? ? 0 : 5,
                                        empty: profit.zero?, future: date > today)
    end
  end
  let(:html) do
    view_context.render(described_class.new(week: week, days: days, best_day_index: best_day_index,
                                            empty_days: empty_days, blank_week: blank_week))
  end
  let(:page_html) { Capybara.string(html) }

  it 'labels the bars from monday to sunday' do
    labels = html.scan(/<span class="text-\[10px\][^"]*">([^<]+)<\/span>/).flatten

    expect(labels).to eq(%w[seg ter qua qui sex sáb dom])
  end

  it 'highlights the best day and scales bars as a share of the track' do
    expect(html).to include('bg-blue-600')
    expect(html).to include('height: 100.0%')
    expect(html).to include('bg-blue-200')
    expect(html).to include('height: 89.6%')
    expect(html).to include('bg-slate-100')
    expect(html).to include('height: 4px')
  end

  it 'grows the track from 96px on the phone to 150px on the desktop' do
    expect(html).to include('h-[96px] lg:h-[150px]')
  end

  context 'with days without records' do
    let(:empty_days) { [Date.new(2026, 7, 8), Date.new(2026, 7, 12)] }

    it 'announces the best day and the days without records' do
      expect(html).to include('Sexta foi o melhor dia:')
      expect(html).to include('R$ 268,00')
      expect(html).to include('Quarta e domingo sem lançamentos.')
    end
  end

  context 'with a loss on monday' do
    let(:profits) { [-50, 0, 0, 0, 0, 0, 0] }
    let(:best_day_index) { nil }

    it 'stubs a day with negative profit' do
      expect(html).to include('bg-slate-100')
      expect(html).to include('height: 4px')
    end
  end

  context 'on a week without profit' do
    let(:profits) { [0, 0, 0, 0, 0, 0, 0] }
    let(:best_day_index) { nil }

    it 'omits the best day sentence when no day is profitable' do
      expect(html).not_to include('melhor dia')
    end

    context 'with three days without records' do
      let(:empty_days) { [Date.new(2026, 7, 7), Date.new(2026, 7, 9), Date.new(2026, 7, 11)] }

      it 'joins three days without records in a sentence' do
        expect(html).to include('Terça, quinta e sábado sem lançamentos.')
      end
    end

    context 'when the whole week is blank' do
      let(:empty_days) { week.range.to_a }
      let(:blank_week) { true }

      it 'says the week has no records instead of the day sentences on a blank week' do
        expect(html).to include('Nenhum lançamento nesta semana.')
        expect(html).not_to include('sem lançamentos')
      end
    end
  end
end
