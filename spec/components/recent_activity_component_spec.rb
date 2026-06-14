require 'rails_helper'

RSpec.describe RecentActivityComponent, type: :component do
  let(:rows) do
    [
      { type: :expense, date: Date.new(2025, 6, 12), date_label: '12 de junho', label: 'Combustível', description: 'Posto Shell', amount: 80.0 },
      { type: :earning, date: Date.new(2025, 6, 10), date_label: '10 de junho', label: 'Uber', description: '3 corridas', amount: 200.0 }
    ]
  end
  let(:html) { view_context.render(RecentActivityComponent.new(rows: rows)) }

  it 'renders the section title' do
    expect(html).to include(I18n.t('recent_activity_component.title'))
  end

  it 'renders one row per item' do
    expect(html.scan('data-recent-activity-row').size).to eq(2)
  end

  it 'uses Truck icon with emerald color for earnings' do
    expect(html).to include('text-emerald-600')
    expect(html).to include('bg-emerald-50')
  end

  it 'uses Receipt icon with red color for expenses' do
    expect(html).to include('text-red-600')
    expect(html).to include('bg-red-50')
  end

  it 'shows earning amounts prefixed with + and expenses with -' do
    expect(html).to include('+ R$')
    expect(html).to include('200,00')
    expect(html).to include('- R$')
    expect(html).to include('80,00')
  end

  it 'shows date label and description for each row' do
    expect(html).to include('12 de junho')
    expect(html).to include('Posto Shell')
    expect(html).to include('3 corridas')
  end

  it 'renders empty state when rows is empty' do
    empty_html = view_context.render(RecentActivityComponent.new(rows: []))

    expect(empty_html).to include(I18n.t('recent_activity_component.empty'))
  end
end
