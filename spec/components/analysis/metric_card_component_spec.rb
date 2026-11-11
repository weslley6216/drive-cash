require 'rails_helper'

RSpec.describe Analysis::MetricCardComponent, type: :component do
  let(:label) { 'R$ / dia' }
  let(:icon) { PhlexIcons::Lucide::Zap }
  let(:value) { 'R$ 250,00' }
  let(:three_months) do
    {
      points: [{ month: 1, value: 10.0 }, { month: 4, value: 30.0 }, { month: 5, value: 20.0 }],
      best:   { month: 4, value: 30.0 }
    }
  end
  let(:two_months) do
    { points: [{ month: 1, value: 10.0 }, { month: 2, value: 20.0 }], best: { month: 2, value: 20.0 } }
  end
  let(:series) { three_months }
  let(:component) { described_class.new(label: label, icon: icon, value: value, series: series) }
  let(:html) { view_context.render(component) }

  it 'renders the label and value without a comparison suffix' do
    expect(html).to include('R$ / dia')
    expect(html).to include('R$ 250,00')
    expect(html).not_to include('vs')
    expect(html).not_to include('%')
  end

  it 'rejects the old comparison params' do
    expect do
      described_class.new(label: label, icon: icon, value: value, series: series, change_pct: 12.5)
    end.to raise_error(ArgumentError)
  end

  it 'renders the sparkline and the best month footer with three or more months' do
    expect(html).to include('viewBox="0 0 100')
    expect(html).to include('>Jan<')
    expect(html).to include('melhor: abr')
    expect(html).to include('text-blue-600')
    expect(html).to include('>Mai<')
  end

  it 'renders no sparkline nor footer with fewer than three months' do
    rendered = view_context.render(described_class.new(label: label, icon: icon, value: value, series: two_months))

    expect(rendered).not_to include('viewBox="0 0 100')
    expect(rendered).not_to include('melhor:')
  end

  it 'adds the best value to the hero footer' do
    rendered = view_context.render(
      described_class.new(label: label, icon: icon, value: value, series: series, variant: :hero)
    )

    expect(rendered).to include('melhor: abr · R$ 30,00')
  end

  it 'shows the not-enough message on the hero with fewer than three months' do
    rendered = view_context.render(
      described_class.new(label: label, icon: icon, value: value, series: two_months, variant: :hero)
    )

    expect(rendered).to include(I18n.t('analysis.show_view.trend.not_enough'))
    expect(html).not_to include(I18n.t('analysis.show_view.trend.not_enough'))
  end

  it 'highlights the hero with a blue border and larger value' do
    hero = view_context.render(
      described_class.new(label: label, icon: icon, value: value, series: series, variant: :hero)
    )

    expect(hero).to include('border-blue-100')
    expect(hero).to include('text-2xl')
    expect(html).to include('border-slate-100')
    expect(html).to include('text-[15px]')
  end
end
