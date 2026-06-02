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
      { unit: :day, key: 5,  label: '5',  earnings: 200.0, expenses: 0.0,  empty: false },
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

    expect(html.scan('bg-emerald-500').size).to eq(daily_bars.size)
    expect(html.scan('bg-red-500').size).to eq(daily_bars.size)
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

  it 'scales bar heights proportionally to the max value' do
    html = view_context.render(Analysis::BarChartComponent.new(bars: daily_bars, month: 6, year: 2025))

    expect(html).to include('height: 130px')
  end

  it 'wraps in overflow-x-auto and uses flex-shrink-0 columns when bars exceed threshold' do
    many_bars = (1..21).map do |day|
      { unit: :day, key: day, label: day.to_s, earnings: 100.0, expenses: 20.0, empty: false }
    end

    html = view_context.render(Analysis::BarChartComponent.new(bars: many_bars, month: 6, year: 2025))

    expect(html).to include('overflow-x-auto')
    expect(html).to include('flex-shrink-0')
    expect(html).to include('min-width:')
  end
end
