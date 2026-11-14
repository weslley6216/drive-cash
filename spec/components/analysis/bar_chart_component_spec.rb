require 'rails_helper'

RSpec.describe Analysis::BarChartComponent, type: :component do
  let(:annual_bars) do
    (1..12).map do |month_number|
      {
        unit: :month, key: month_number,
        label: I18n.t('date.abbr_month_names')[month_number].capitalize,
        earnings: month_number == 6 ? 500.0 : 0.0,
        expenses: month_number == 6 ? 100.0 : 0.0,
        empty: month_number != 6
      }
    end
  end

  let(:daily_bars) do
    [
      { unit: :day, key: 5, label: '5', earnings: 200.0, expenses: 0.0, empty: false },
      { unit: :day, key: 10, label: '10', earnings: 300.0, expenses: 50.0, empty: false }
    ]
  end

  it 'renders annual subtitle with year when month is nil' do
    html = view_context.render(Analysis::BarChartComponent.new(bars: annual_bars, month: nil, year: 2025))

    expect(html).to include(I18n.t('analysis.show_view.bar_chart.subtitle_annual', year: 2025))
  end

  it 'renders monthly subtitle with month name and year when month is present' do
    html = view_context.render(Analysis::BarChartComponent.new(bars: daily_bars, month: 6, year: 2025))

    month_name = I18n.t('date.month_names')[6].capitalize
    expect(html).to include(I18n.t('analysis.show_view.bar_chart.subtitle_monthly', month_name: month_name, year: 2025))
  end

  it 'renders the chart title from locale' do
    html = view_context.render(Analysis::BarChartComponent.new(bars: annual_bars, month: nil, year: 2025))

    expect(html).to include(I18n.t('analysis.show_view.bar_chart.title'))
  end

  it 'renders one earnings bar and one expense bar per non-empty entry' do
    html = view_context.render(Analysis::BarChartComponent.new(bars: daily_bars, month: 6, year: 2025))

    expect(html.scan('rounded-t bg-emerald-500').size).to eq(daily_bars.size)
    expect(html.scan('rounded-t bg-red-500').size).to eq(daily_bars.size)
  end

  it 'renders a stub gray bar for empty months in annual mode' do
    html = view_context.render(Analysis::BarChartComponent.new(bars: annual_bars, month: nil, year: 2025))

    expect(html).to include('bg-slate-200')
  end

  it 'renders empty state when bars is empty' do
    html = view_context.render(Analysis::BarChartComponent.new(bars: [], month: nil, year: 2025))

    expect(html).not_to include('bg-emerald-500')
    expect(html).to include(I18n.t('analysis.show_view.bar_chart.empty'))
  end

  it 'renders labels for each bar entry' do
    html = view_context.render(Analysis::BarChartComponent.new(bars: daily_bars, month: 6, year: 2025))

    expect(html).to include('5')
    expect(html).to include('10')
  end

  it 'renders the legend for earnings and expenses when bars are present' do
    html = view_context.render(Analysis::BarChartComponent.new(bars: daily_bars, month: 6, year: 2025))

    expect(html).to include(I18n.t('analysis.show_view.bar_chart.legend_earnings'))
    expect(html).to include(I18n.t('analysis.show_view.bar_chart.legend_expenses'))
  end

  it 'scales bar heights as a share of the prototype plot height' do
    html = view_context.render(Analysis::BarChartComponent.new(bars: daily_bars, month: 6, year: 2025))

    expect(html).to include('h-[118px] lg:h-[206px]')
    expect(html).to include('height: 100.0%')
    expect(html).to include('height: 16.7%')
  end

  it 'draws thin bars like the prototype for months and days' do
    annual = view_context.render(Analysis::BarChartComponent.new(bars: annual_bars, month: nil, year: 2025))
    daily = view_context.render(Analysis::BarChartComponent.new(bars: daily_bars, month: 6, year: 2025))

    expect(annual).to include('rounded-t bg-emerald-500 w-[5px] lg:w-3')
    expect(daily).to include('rounded-t bg-emerald-500 w-[3px] lg:w-1.5')
    expect(annual).to include('rounded-full bg-slate-200 h-[3px] w-[5px] lg:w-3')
  end

  it 'uses 9px labels and labels about eight days in the daily view' do
    many_bars = (1..20).map do |day|
      { unit: :day, key: day, label: day.to_s, earnings: 100.0, expenses: 20.0, empty: false }
    end

    html = view_context.render(Analysis::BarChartComponent.new(bars: many_bars, month: 3, year: 2025))

    expect(html).to include('text-[9px] leading-none min-h-[10px]')
    expect(html).to include('font-medium">4</span>')
    expect(html).not_to include('font-medium">2</span>')
    expect(html).to include('font-medium">20</span>')
  end

  it 'uses the prototype legend colors and the wider desktop card' do
    html = view_context.render(Analysis::BarChartComponent.new(bars: daily_bars, month: 6, year: 2025))

    expect(html).to include('w-2 h-2 lg:w-2.5 lg:h-2.5 rounded-sm bg-emerald-500')
    expect(html).to include('lg:border-slate-200 lg:shadow-none lg:p-6')
  end

  it 'renders many daily bars using fluid flex-1 min-w-0 columns without overflow wrappers' do
    many_bars = (1..31).map do |day|
      { unit: :day, key: day, label: day.to_s, earnings: 100.0, expenses: 20.0, empty: false }
    end

    html = view_context.render(Analysis::BarChartComponent.new(bars: many_bars, month: 3, year: 2025))

    expect(html).to include('flex-1 min-w-0')
    expect(html).not_to include('overflow-x-auto')
    expect(html.scan('rounded-t bg-emerald-500').size).to eq(31)
  end

  it 'wraps the chart in a relative container wired to the bar-tooltip controller' do
    html = view_context.render(Analysis::BarChartComponent.new(bars: daily_bars, month: 6, year: 2025))

    expect(html).to include('data-controller="bar-tooltip"')
    expect(html).to include('class="relative lg:mt-6"')
  end

  it 'renders the dark tooltip node with an arrow and colored dots, hidden by default' do
    html = view_context.render(Analysis::BarChartComponent.new(bars: daily_bars, month: 6, year: 2025))

    expect(html).to include('data-bar-tooltip-target="tooltip"')
    expect(html).to include('bg-slate-900')
    expect(html).to include('rotate(45deg)')
    expect(html).to include('bg-emerald-400')
    expect(html).to include('bg-red-400')
    expect(html).to include('hidden')
  end

  it 'exposes each non-empty column with index and earnings and expenses formatted in BRL' do
    html = view_context.render(Analysis::BarChartComponent.new(bars: daily_bars, month: 6, year: 2025))

    expect(html.scan('data-bar-tooltip-target="column"').size).to eq(daily_bars.size)
    expect(html).to include('data-index="0"')
    expect(html).to include('data-index="1"')
    expect(html).to include("data-earn=\"R$ 200,00\"")
    expect(html).to include("data-exp=\"R$ 50,00\"")
  end

  it 'wires stimulus actions for hover, focus, click and keyboard on each column' do
    html = view_context.render(Analysis::BarChartComponent.new(bars: daily_bars, month: 6, year: 2025))

    expect(html).to include('mouseenter->bar-tooltip#show')
    expect(html).to include('mouseleave->bar-tooltip#hide')
    expect(html).to include('focus->bar-tooltip#show')
    expect(html).to include('blur->bar-tooltip#hide')
    expect(html).to include('click->bar-tooltip#toggle')
    expect(html).to include('keydown.enter->bar-tooltip#toggle')
  end

  it 'makes each column a focusable button with an aria-label describing period and values' do
    html = view_context.render(Analysis::BarChartComponent.new(bars: daily_bars, month: 6, year: 2025))

    expect(html.scan('role="button"').size).to eq(daily_bars.size)
    expect(html.scan('tabindex="0"').size).to eq(daily_bars.size)
    expect(html).to include('aria-label="Dia 5: Receita R$ 200,00, Despesa R$ 0,00"')
  end

  it 'uses the "Dia N" tooltip label in daily mode' do
    html = view_context.render(Analysis::BarChartComponent.new(bars: daily_bars, month: 6, year: 2025))

    expect(html).to include('data-label-text="Dia 5"')
  end

  it 'uses the month abbreviation as the tooltip label in annual mode' do
    html = view_context.render(Analysis::BarChartComponent.new(bars: annual_bars, month: nil, year: 2025))

    june_abbr = I18n.t('date.abbr_month_names')[6].capitalize
    expect(html).to include(%(data-label-text="#{june_abbr}"))
  end

  it 'marks empty columns as muted with a no-data aria-label' do
    html = view_context.render(Analysis::BarChartComponent.new(bars: annual_bars, month: nil, year: 2025))

    expect(html).to include('data-muted="true"')
    jan_abbr = I18n.t('date.abbr_month_names')[1].capitalize
    expect(html).to include(%(aria-label="#{jan_abbr}: Sem dados"))
  end

  it 'renders future months as inert columns that keep their space and label' do
    bars = annual_bars.map { |bar| bar.merge(future: bar[:key] > 6) }

    html = view_context.render(Analysis::BarChartComponent.new(bars: bars, month: nil, year: 2026))
    july = I18n.t('date.abbr_month_names')[7].capitalize

    expect(html).to include(%(<div class="flex-1 min-w-0 flex flex-col items-center gap-1 pt-0.5 cursor-default" aria-hidden="true" data-future="true">))
    expect(html).to include(%(text-slate-300 font-medium">#{july}</span>))
    expect(html).not_to include(%(aria-label="#{july}: Sem dados"))
    expect(html.scan('role="button"').size).to eq(6)
  end

  it 'renders the no-data label inside the tooltip node' do
    html = view_context.render(Analysis::BarChartComponent.new(bars: daily_bars, month: 6, year: 2025))

    expect(html).to include(I18n.t('analysis.show_view.bar_chart.tooltip_no_data'))
  end
end
