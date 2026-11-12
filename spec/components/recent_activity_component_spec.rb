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

  it 'glues the sign to the amount with a typographic minus for expenses' do
    expect(html).to include('+R$ 200,00')
    expect(html).to include("\u2212R$ 80,00")
  end

  it 'shows the description before the date on phones and the date in its own column on desktops' do
    expect(html).to include('Posto Shell<span class="lg:hidden"> · 12 de junho</span>')
    expect(html).to include('<span class="hidden lg:block text-xs text-slate-400 w-20">10 de junho</span>')
  end

  it 'links to the history with the prototype see-all labels' do
    expect(html).to include('href="/history"')
    expect(html).to include(I18n.t('recent_activity_component.see_all'))
    expect(html).to include(I18n.t('recent_activity_component.see_all_desktop'))
  end

  it 'uses the prototype card and square icons' do
    expect(html).to include('bg-white rounded-xl shadow-sm border border-slate-100 lg:border-slate-200 lg:shadow-none')
    expect(html).to include('w-9 h-9 lg:w-10 lg:h-10 rounded-lg')
  end

  it 'renders empty state when rows is empty' do
    empty_html = view_context.render(RecentActivityComponent.new(rows: []))

    expect(empty_html).to include(I18n.t('recent_activity_component.empty'))
  end
end
