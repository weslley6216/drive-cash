require 'rails_helper'

RSpec.describe Analysis::BarChartComponent, type: :component do
  let(:months) do
    [
      { month: 4, earnings: 500.0, expenses: 100.0, label: 'Abr' },
      { month: 5, earnings: 800.0, expenses: 200.0, label: 'Mai' },
      { month: 6, earnings: 600.0, expenses: 150.0, label: 'Jun' }
    ]
  end
  let(:html) { view_context.render(Analysis::BarChartComponent.new(months: months)) }

  it 'renders the chart title and subtitle from locale' do
    expect(html).to include(I18n.t('analysis.show_view.bar_chart.title'))
    expect(html).to include(I18n.t('analysis.show_view.bar_chart.subtitle'))
  end

  it 'renders one earnings (green) bar per month' do
    expect(html.scan('bg-emerald-500').size).to eq(months.size)
  end

  it 'renders one expense (red) bar per month' do
    expect(html.scan('bg-red-500').size).to eq(months.size)
  end

  it 'labels each month' do
    expect(html).to include('Abr')
    expect(html).to include('Mai')
    expect(html).to include('Jun')
  end

  it 'renders the legend for earnings and expenses' do
    expect(html).to include(I18n.t('analysis.show_view.bar_chart.legend_earnings'))
    expect(html).to include(I18n.t('analysis.show_view.bar_chart.legend_expenses'))
  end

  it 'renders empty state when months is empty' do
    empty = view_context.render(Analysis::BarChartComponent.new(months: []))

    expect(empty).not_to include('bg-emerald-500')
  end

  it 'scales bar heights proportionally to the max value' do
    expect(html).to include('height: 130px')
  end
end
