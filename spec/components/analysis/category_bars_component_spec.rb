require 'rails_helper'

RSpec.describe Analysis::CategoryBarsComponent, type: :component do
  let(:categories) do
    [
      { id: 'fuel',        label: 'Combustível', amount: 300.0, percent: 60.0, color: '#dc2626', icon: PhlexIcons::Lucide::Fuel },
      { id: 'maintenance', label: 'Manutenção',  amount: 200.0, percent: 40.0, color: '#f97316', icon: PhlexIcons::Lucide::Wrench }
    ]
  end
  let(:html) { view_context.render(Analysis::CategoryBarsComponent.new(categories: categories)) }

  it 'renders the section title' do
    expect(html).to include(I18n.t('analysis.show_view.categories.title'))
  end

  it 'renders total expenses as subtitle in "X no ano" format' do
    expect(html).to include(I18n.t('analysis.show_view.categories.total_year', value: 'R$ 500,00'))
  end

  it 'renders a row per category with label and color' do
    expect(html.scan('data-category-row').size).to eq(2)
    expect(html).to include('Combustível')
    expect(html).to include('Manutenção')
  end

  it 'renders icon in a soft-color bubble using the category color' do
    expect(html).to include('#dc262620')
    expect(html).to include('color: #dc2626')
  end

  it 'renders percent before amount per row' do
    fuel_row = html[html.index('Combustível')..html.index('Manutenção')]

    expect(fuel_row.index('60.0')).to be < fuel_row.index('300,00')
  end

  it 'renders the bar width proportional to the percent' do
    expect(html).to include('width: 60.0%')
    expect(html).to include('width: 40.0%')
  end

  it 'uses h-1.5 for the progress bar height' do
    expect(html).to include('h-1.5')
  end

  it 'renders empty state when categories is empty' do
    empty = view_context.render(Analysis::CategoryBarsComponent.new(categories: []))

    expect(empty).to include(I18n.t('category_breakdown_component.empty'))
  end
end
