require 'rails_helper'

RSpec.describe HeroProfitCardComponent, type: :component do
  let(:series) { [100.0, 200.0, -50.0, 300.0, 400.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0] }
  let(:component) do
    HeroProfitCardComponent.new(
      profit: 950.0,
      change_percent: 12.5,
      profit_per_day: 47.5,
      days_count: 20,
      monthly_series: series,
      year: 2025,
      month: nil
    )
  end
  let(:html) { view_context.render(component) }

  it 'renders a pastel blue card with rounded corners' do
    expect(html).to include('bg-blue-50')
    expect(html).to include('border-blue-200')
    expect(html).to include('rounded-2xl')
  end

  it 'renders the profit value formatted as BRL currency' do
    expect(html).to include('950,00')
  end

  it 'renders the year label when month is nil' do
    expect(html).to include(I18n.t('hero_profit_card_component.label_year', year: 2025))
  end

  it 'renders the month/year label when month is present' do
    monthly = HeroProfitCardComponent.new(
      profit: 500.0, change_percent: nil, profit_per_day: 25.0, days_count: 20,
      monthly_series: series, year: 2025, month: 6
    )

    month_name = I18n.t('date.month_names')[6]
    expect(view_context.render(monthly)).to include(
      I18n.t('hero_profit_card_component.label_month', month: month_name, year: 2025)
    )
  end

  it 'renders positive change badge in green when change_percent is positive' do
    expect(html).to include(I18n.t('hero_profit_card_component.change_positive', value: '12.5'))
    expect(html).to include('text-emerald-700')
  end

  it 'renders negative change badge in red when change_percent is negative' do
    negative = HeroProfitCardComponent.new(
      profit: 100, change_percent: -8.0, profit_per_day: 5, days_count: 20,
      monthly_series: series, year: 2025, month: 6
    )

    rendered = view_context.render(negative)

    expect(rendered).to include('text-red-700')
    expect(rendered).to include(I18n.t('hero_profit_card_component.change_negative', value: '-8.0'))
  end

  it 'does not render a change badge when change_percent is nil' do
    no_change = HeroProfitCardComponent.new(
      profit: 100, change_percent: nil, profit_per_day: 5, days_count: 20,
      monthly_series: series, year: 2025, month: nil
    )

    rendered = view_context.render(no_change)

    expect(rendered).not_to include('text-emerald-700')
    expect(rendered).not_to include('text-red-700')
  end

  it 'renders profit per day with days count' do
    expect(html).to include('47,50')
    expect(html).to include('20 dias trabalhados')
  end

  it 'renders zero-days message when days_count is zero' do
    zero = HeroProfitCardComponent.new(
      profit: 0, change_percent: nil, profit_per_day: 0, days_count: 0,
      monthly_series: series, year: 2025, month: 6
    )

    expect(view_context.render(zero)).to include(I18n.t('hero_profit_card_component.per_day_zero'))
  end

  it 'plots one circle per non-future month (drops trailing zeros)' do
    circles = html.scan(/<circle/)

    expect(html).to include('<svg')
    expect(html).to include('<path')
    expect(html).to include('<circle')
    expect(circles.size).to eq(5)
  end

  it 'renders chart with gradient fill' do
    expect(html).to include('profitFill')
    expect(html).to include('stop-color')
    expect(html).to include('linearGradient')
  end

  it 'renders circles for data points' do
    circles = html.scan(/<circle/)

    expect(circles.size).to eq(5)
    expect(html).to include('stroke="#1d4ed8"')
  end

  it 'renders month labels below the chart' do
    expect(html).to include('Jan')
    expect(html).to include('Fev')
    expect(html).to include('Mar')
    expect(html).to include('Abr')
    expect(html).to include('Mai')
  end

  it 'plots all points when there are no trailing zeros' do
    full = HeroProfitCardComponent.new(
      profit: 1200.0, change_percent: nil, profit_per_day: 100.0, days_count: 12,
      monthly_series: [100.0, 200.0, 150.0, 300.0, 250.0, 180.0, 220.0, 270.0, 310.0, 280.0, 350.0, 400.0],
      year: 2025, month: nil
    )

    circles = view_context.render(full).scan(/<circle/)

    expect(circles.size).to eq(12)
  end

  it 'drops leading and trailing zeros' do
    mixed = HeroProfitCardComponent.new(
      profit: 500.0, change_percent: nil, profit_per_day: 50.0, days_count: 10,
      monthly_series: [0.0, 0.0, 100.0, 0.0, 200.0, 0.0, 0.0, 0.0],
      year: 2025, month: nil
    )

    circles = view_context.render(mixed).scan(/<circle/)

    expect(circles.size).to eq(3)
  end

  it 'omits the SVG path when all series values are zero' do
    flat = HeroProfitCardComponent.new(
      profit: 0, change_percent: nil, profit_per_day: 0, days_count: 0,
      monthly_series: [0.0] * 12, year: 2025, month: nil
    )

    expect(view_context.render(flat)).not_to include('<path')
  end
end
