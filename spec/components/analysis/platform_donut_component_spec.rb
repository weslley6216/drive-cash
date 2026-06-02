require 'rails_helper'

RSpec.describe Analysis::PlatformDonutComponent, type: :component do
  let(:platforms) do
    [
      { id: 'uber',  label: 'Uber',  amount: 750.0, percent: 75.0, color: '#000000' },
      { id: 'ifood', label: 'iFood', amount: 250.0, percent: 25.0, color: '#ea1d2c' }
    ]
  end
  let(:component) { Analysis::PlatformDonutComponent.new(platforms: platforms, total: 1000.0) }
  let(:html) { view_context.render(component) }

  it 'renders the section title and total_year subtitle' do
    expect(html).to include(I18n.t('analysis.show_view.platforms.title'))
    expect(html).to include(I18n.t('analysis.show_view.platforms.total_year', value: 'R$ 1.000,00'))
  end

  it 'renders one circle segment per platform (no background ring)' do
    expect(html.scan('<circle').size).to eq(platforms.size)
  end

  it 'renders each platform segment color' do
    expect(html).to include('#000000')
    expect(html).to include('#ea1d2c')
  end

  it 'uses stroke-dasharray to draw the donut segments' do
    expect(html).to include('stroke-dasharray')
  end

  it 'renders the total_label and rounded total in the donut center overlay' do
    expect(html).to include(I18n.t('analysis.show_view.platforms.total_label'))
    expect(html).to include('1.000')
  end

  it 'renders a side legend with label and percent only (no amount)' do
    expect(html).to include('Uber')
    expect(html).to include('iFood')
    expect(html).to include('75.0%')
    expect(html).to include('25.0%')
    expect(html).not_to include('750,00')
  end

  it 'renders empty state when platforms is empty' do
    empty = view_context.render(Analysis::PlatformDonutComponent.new(platforms: [], total: 0))

    expect(empty).to include(I18n.t('analysis.show_view.platforms.empty'))
  end
end
