require 'rails_helper'

RSpec.describe Analysis::PlatformDonutComponent, type: :component do
  let(:platforms) do
    [
      { id: 'uber', label: 'Uber', amount: 750.0, percent: 75.0 },
      { id: 'ifood', label: 'iFood', amount: 250.0, percent: 25.0 }
    ]
  end

  it 'renders total_annual subtitle when month is nil' do
    html = view_context.render(Analysis::PlatformDonutComponent.new(platforms: platforms, total: 1000.0, month: nil))

    expect(html).to include(I18n.t('analysis.show_view.platforms.total_annual', value: 'R$ 1.000,00'))
    expect(html).not_to include('no mês')
  end

  it 'renders total_monthly subtitle when month is present' do
    html = view_context.render(Analysis::PlatformDonutComponent.new(platforms: platforms, total: 1000.0, month: 6))

    expect(html).to include(I18n.t('analysis.show_view.platforms.total_monthly', value: 'R$ 1.000,00'))
    expect(html).not_to include('no ano')
  end

  it 'renders the section title' do
    html = view_context.render(Analysis::PlatformDonutComponent.new(platforms: platforms, total: 1000.0, month: nil))

    expect(html).to include(I18n.t('analysis.show_view.platforms.title'))
  end

  it 'renders one circle segment per platform (no background ring)' do
    html = view_context.render(Analysis::PlatformDonutComponent.new(platforms: platforms, total: 1000.0, month: nil))

    expect(html.scan('<circle').size).to eq(platforms.size)
  end

  it 'renders each platform segment color' do
    html = view_context.render(Analysis::PlatformDonutComponent.new(platforms: platforms, total: 1000.0, month: nil))

    expect(html).to include('#000000')
    expect(html).to include('#ea1d2c')
  end

  it 'uses stroke-dasharray to draw the donut segments' do
    html = view_context.render(Analysis::PlatformDonutComponent.new(platforms: platforms, total: 1000.0, month: nil))

    expect(html).to include('stroke-dasharray')
  end

  it 'renders the total_label and rounded total in the donut center overlay' do
    html = view_context.render(Analysis::PlatformDonutComponent.new(platforms: platforms, total: 1000.0, month: nil))

    expect(html).to include(I18n.t('analysis.show_view.platforms.total_label'))
    expect(html).to include('1.000')
  end

  it 'renders a side legend with label and percent only (no amount)' do
    html = view_context.render(Analysis::PlatformDonutComponent.new(platforms: platforms, total: 1000.0, month: nil))

    expect(html).to include('Uber')
    expect(html).to include('iFood')
    expect(html).to include('75.0%')
    expect(html).to include('25.0%')
    expect(html).not_to include('750,00')
  end

  it 'renders empty state when platforms is empty' do
    html = view_context.render(Analysis::PlatformDonutComponent.new(platforms: [], total: 0, month: nil))

    expect(html).to include(I18n.t('analysis.show_view.platforms.empty'))
  end
end
