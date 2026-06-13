require 'rails_helper'

RSpec.describe CategoryBreakdownComponent, type: :component do
  let(:categories) do
    [
      { id: 'fuel',        label: 'Combustível', amount: 300.0, percent: 60.0 },
      { id: 'maintenance', label: 'Manutenção',  amount: 200.0, percent: 40.0 }
    ]
  end
  let(:html) { view_context.render(CategoryBreakdownComponent.new(categories: categories)) }

  it 'renders the section title' do
    expect(html).to include(I18n.t('category_breakdown_component.title'))
  end

  it 'renders one mini bar per category with percent and color' do
    expect(html.scan('data-category-row').size).to eq(2)
    expect(html).to include(I18n.t('category_breakdown_component.percent', value: '60.0'))
    expect(html).to include(I18n.t('category_breakdown_component.percent', value: '40.0'))
    expect(html).to include('#dc2626')
    expect(html).to include('#f97316')
    expect(html).to include('width: 60.0%')
    expect(html).to include('width: 40.0%')
  end

  it 'renders translated label and formatted amount for each category' do
    expect(html).to include('Combustível')
    expect(html).to include('Manutenção')
    expect(html).to include('300,00')
    expect(html).to include('200,00')
  end

  it 'renders empty state when categories is empty' do
    empty_html = view_context.render(CategoryBreakdownComponent.new(categories: []))

    expect(empty_html).to include(I18n.t('category_breakdown_component.empty'))
  end
end
