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
    expect(rendered).to include(I18n.t('hero_profit_card_component.change_negative', value: '8.0'))
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

  it 'renders two SVG charts — mobile and desktop' do
    expect(html.scan('viewBox="0 0').size).to eq(2)
  end

  it 'renders mobile chart hidden on desktop' do
    expect(html).to include('lg:hidden')
  end

  it 'renders desktop chart hidden on mobile' do
    expect(html).to include('hidden lg:block')
  end

  it 'uses mobile viewBox 320x70' do
    expect(html).to include('viewBox="0 0 320 70"')
  end

  it 'uses desktop viewBox 720x120' do
    expect(html).to include('viewBox="0 0 720 120"')
  end

  it 'renders gradient fills for each chart' do
    expect(html).to include('profitFillMobile')
    expect(html).to include('profitFillDesktop')
  end

  it 'renders responsive text sizes for header' do
    expect(html).to include('lg:text-5xl')
    expect(html).to include('lg:text-sm')
  end

  it 'renders change badge with border styling' do
    expect(html).to include('border')
    expect(html).to include('border-emerald-200')
  end

  it 'renders month labels trimming leading zeros' do
    series_with_leading = [0.0, 0.0, 100.0, 200.0, 300.0]
    comp = HeroProfitCardComponent.new(
      profit: 600, change_percent: nil, profit_per_day: 30, days_count: 20,
      monthly_series: series_with_leading, year: 2025, month: nil
    )
    rendered = view_context.render(comp)
    expect(rendered).not_to include('>Jan<')
    expect(rendered).not_to include('>Fev<')
    expect(rendered).to include('Mar')
  end

  it 'omits the SVG path when all series values are zero' do
    flat = HeroProfitCardComponent.new(
      profit: 0, change_percent: nil, profit_per_day: 0, days_count: 0,
      monthly_series: [0.0] * 12, year: 2025, month: nil
    )

    expect(view_context.render(flat)).not_to include('<path')
  end

  it 'renders month abbreviations below the chart' do
    expect(html).to include('Jan')
    expect(html).to include('Fev')
    expect(html).to include('Mar')
  end

  context 'when daily_mode: true' do
    let(:daily_series) { [0.0] * 9 + [400.0, 0.0, 80.0] + [0.0] * 19 }
    let(:component) do
      HeroProfitCardComponent.new(
        profit: 480, change_percent: nil, profit_per_day: 160, days_count: 2,
        monthly_series: daily_series, year: 2025, month: 1, daily_mode: true
      )
    end
    let(:html) { view_context.render(component) }

    it 'renders chart including zero-value days' do
      expect(html).to include('viewBox="0 0 320 70"')
      expect(html).to include('<path')
    end

    it 'plots all days including zeros without trimming' do
      expect(html.scan('<circle').size).to eq(daily_series.size * 2)
    end

    it 'does not render month label abbreviations' do
      expect(html).not_to include('>Jan<')
      expect(html).not_to include('>Fev<')
    end
  end
end
