require 'rails_helper'

RSpec.describe Analysis::MetricCardComponent, type: :component do
  let(:component) do
    Analysis::MetricCardComponent.new(
      label: 'R$ / dia',
      icon: PhlexIcons::Lucide::Zap,
      value: 'R$ 250,00',
      change_pct: 12.5
    )
  end
  let(:html) { view_context.render(component) }

  it 'renders the label and value' do
    expect(html).to include('R$ / dia')
    expect(html).to include('R$ 250,00')
  end

  it 'renders icon and label on the same line' do
    expect(html).to include('flex items-center gap-2')
  end

  it 'renders the hint when present' do
    with_hint = Analysis::MetricCardComponent.new(
      label: 'R$ / hora *', icon: PhlexIcons::Lucide::Clock, value: 'R$ 29,85', hint: '*estimado em 8h/dia'
    )

    expect(view_context.render(with_hint)).to include('*estimado em 8h/dia')
  end

  it 'renders the change badge in green as simple text when change_pct is positive' do
    expect(html).to include('text-emerald-600')
    expect(html).to include('+12.5% vs anterior')
    expect(html).not_to include('rounded-full')
  end

  it 'renders the change badge in red as simple text when change_pct is negative' do
    negative = Analysis::MetricCardComponent.new(
      label: 'Margem', icon: PhlexIcons::Lucide::Gauge, value: '20%', change_pct: -8.0
    )

    rendered = view_context.render(negative)

    expect(rendered).to include('text-red-600')
    expect(rendered).to include('−8.0% vs anterior')
  end

  it 'formats badge as "p.p." when pp: true' do
    pp_card = Analysis::MetricCardComponent.new(
      label: 'Margem', icon: PhlexIcons::Lucide::Gauge, value: '56,1%', change_pct: 3.2, pp: true
    )

    rendered = view_context.render(pp_card)

    expect(rendered).to include('+3.2 p.p. vs anterior')
    expect(rendered).not_to include('% vs anterior')
  end

  it 'does not render the change badge when change_pct is nil' do
    no_change = Analysis::MetricCardComponent.new(
      label: 'Margem', icon: PhlexIcons::Lucide::Gauge, value: '20%'
    )

    rendered = view_context.render(no_change)

    expect(rendered).not_to include('text-emerald-600')
    expect(rendered).not_to include('text-red-600')
  end

  it 'renders the provided icon' do
    expect(html).to include('lucide')
  end

  it 'renders period_label when provided instead of generic vs_previous' do
    component = Analysis::MetricCardComponent.new(
      label: 'R$ / dia', icon: PhlexIcons::Lucide::Zap,
      value: 'R$ 250,00', change_pct: 12.5, period_label: 'vs Jan–Jun 2025'
    )

    rendered = view_context.render(component)

    expect(rendered).to include('+12.5% vs Jan–Jun 2025')
    expect(rendered).not_to include('vs anterior')
  end

  it 'falls back to generic vs_previous when period_label is nil' do
    component = Analysis::MetricCardComponent.new(
      label: 'R$ / dia', icon: PhlexIcons::Lucide::Zap,
      value: 'R$ 250,00', change_pct: 12.5
    )

    rendered = view_context.render(component)

    expect(rendered).to include('% vs anterior')
  end
end
