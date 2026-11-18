require 'rails_helper'

RSpec.describe WeeklySummaries::TopCategoriesComponent, type: :component do
  let(:categories) do
    [
      WeeklySummaries::Builder::TopCategory.new(key: 'fuel', amount: 312),
      WeeklySummaries::Builder::TopCategory.new(key: 'meals', amount: 98),
      WeeklySummaries::Builder::TopCategory.new(key: 'toll', amount: 64)
    ]
  end

  it 'lists the categories with their totals under the paid expenses of the week' do
    html = Capybara.string(view_context.render(described_class.new(categories: categories, total: 525)))

    expect(html).to have_text('Onde foi o dinheiro')
    expect(html).to have_text('R$ 525,00')
    expect(html).to have_text('Combustível')
    expect(html).to have_text('Refeições')
    expect(html).to have_text('Pedágio')
    expect(html).to have_text('R$ 312,00')
    expect(html).to have_css('span.bg-red-50.text-red-600', count: 3)
  end

  it 'scales each bar to the biggest category' do
    html = view_context.render(described_class.new(categories: categories, total: 525))

    expect(html).to include('width: 100.0%')
    expect(html).to include('width: 31.4%')
    expect(html).to include('width: 20.5%')
  end

  it 'renders a single category' do
    html = Capybara.string(view_context.render(described_class.new(categories: categories.first(1), total: 312)))

    expect(html).to have_css('.bg-red-400', count: 1)
  end

  it 'renders nothing without expenses' do
    html = view_context.render(described_class.new(categories: [], total: 0))

    expect(html).to eq('')
  end
end
