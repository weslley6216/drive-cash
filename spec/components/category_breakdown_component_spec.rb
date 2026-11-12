require 'rails_helper'

RSpec.describe CategoryBreakdownComponent, type: :component do
  let(:categories) do
    [
      { id: 'fuel', label: 'Combustível', amount: 300.0, percent: 60.0 },
      { id: 'maintenance', label: 'Manutenção', amount: 200.0, percent: 40.0 }
    ]
  end
  let(:html) { view_context.render(CategoryBreakdownComponent.new(categories: categories)) }

  it 'renders the section title' do
    expect(html).to include(I18n.t('category_breakdown_component.title'))
  end

  it 'renders one mini bar per category with percent and color' do
    expect(html.scan('data-category-row').size).to eq(2)
    expect(html).to include(I18n.t('category_breakdown_component.percent', value: '60,0'))
    expect(html).to include(I18n.t('category_breakdown_component.percent', value: '40,0'))
    expect(html).to include('#dc2626')
    expect(html).to include('#f59e0b')
    expect(html).to include('width: 60.0%')
    expect(html).to include('width: 40.0%')
  end

  it 'renders translated label and formatted amount for each category' do
    expect(html).to include('Combustível')
    expect(html).to include('Manutenção')
    expect(html).to include('300,00')
    expect(html).to include('200,00')
  end

  it 'writes the percent with a decimal comma for desktops only' do
    expect(html).to include('<span class="hidden lg:inline text-slate-400">60,0%</span>')
  end

  it 'links to the analysis' do
    expect(html).to include('href="/analysis"')
    expect(html).to include(I18n.t('category_breakdown_component.see_analysis'))
  end

  it 'shows four categories on phones, five on desktops and drops the rest' do
    many = %w[fuel maintenance meals toll car_wash phone].each_with_index.map do |id, index|
      { id: id, label: id, amount: 100.0 - index, percent: 10.0 }
    end

    many_html = view_context.render(described_class.new(categories: many))

    expect(many_html.scan('data-category-row').size).to eq(5)
    expect(many_html).to include('data-category-row="car_wash" class="hidden lg:block"')
    expect(many_html).not_to include('data-category-row="phone"')
  end

  it 'renders empty state when categories is empty' do
    empty_html = view_context.render(CategoryBreakdownComponent.new(categories: []))

    expect(empty_html).to include(I18n.t('category_breakdown_component.empty'))
  end
end
