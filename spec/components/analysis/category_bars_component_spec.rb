require 'rails_helper'

RSpec.describe Analysis::CategoryBarsComponent, type: :component do
  let(:categories) do
    [
      { id: 'fuel',        label: 'Combustível', amount: 300.0, percent: 60.0, color: '#dc2626', icon: PhlexIcons::Lucide::Fuel },
      { id: 'maintenance', label: 'Manutenção',  amount: 200.0, percent: 40.0, color: '#f97316', icon: PhlexIcons::Lucide::Wrench }
    ]
  end

  it 'renders total_annual subtitle when month is nil' do
    html = view_context.render(Analysis::CategoryBarsComponent.new(categories: categories, month: nil))

    expect(html).to include(I18n.t('analysis.show_view.categories.total_annual', value: 'R$ 500,00'))
    expect(html).not_to include('no mês')
  end

  it 'renders total_monthly subtitle when month is present' do
    html = view_context.render(Analysis::CategoryBarsComponent.new(categories: categories, month: 6))

    expect(html).to include(I18n.t('analysis.show_view.categories.total_monthly', value: 'R$ 500,00'))
    expect(html).not_to include('no ano')
  end

  it 'renders the section title' do
    html = view_context.render(Analysis::CategoryBarsComponent.new(categories: categories, month: nil))

    expect(html).to include(I18n.t('analysis.show_view.categories.title'))
  end

  it 'renders a row per category with label and color' do
    html = view_context.render(Analysis::CategoryBarsComponent.new(categories: categories, month: nil))

    expect(html.scan('data-category-row').size).to eq(2)
    expect(html).to include('Combustível')
    expect(html).to include('Manutenção')
  end

  it 'renders icon in a soft-color bubble using the category color' do
    html = view_context.render(Analysis::CategoryBarsComponent.new(categories: categories, month: nil))

    expect(html).to include('#dc262620')
    expect(html).to include('color: #dc2626')
  end

  it 'renders percent before amount per row' do
    html = view_context.render(Analysis::CategoryBarsComponent.new(categories: categories, month: nil))
    fuel_row = html[html.index('Combustível')..html.index('Manutenção')]

    expect(fuel_row.index('60.0')).to be < fuel_row.index('300,00')
  end

  it 'renders the bar width proportional to the percent' do
    html = view_context.render(Analysis::CategoryBarsComponent.new(categories: categories, month: nil))

    expect(html).to include('width: 60.0%')
    expect(html).to include('width: 40.0%')
  end

  it 'uses h-1.5 for the progress bar height' do
    html = view_context.render(Analysis::CategoryBarsComponent.new(categories: categories, month: nil))

    expect(html).to include('h-1.5')
  end

  it 'renders empty state when categories is empty' do
    html = view_context.render(Analysis::CategoryBarsComponent.new(categories: [], month: nil))

    expect(html).to include(I18n.t('analysis.show_view.categories.empty'))
  end
end
