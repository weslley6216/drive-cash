require 'rails_helper'

RSpec.describe History::ModeToggleComponent, type: :component do
  before { travel_to Time.zone.local(2026, 5, 22, 10, 0) }

  def render_toggle(slice, query: nil) = Capybara.string(view_context.render(described_class.new(slice: slice, query: query)))

  it 'marks the month mode and links to the twelve months of the same slice and search' do
    page = render_toggle(History::Slice.new(categories: %w[insurance]), query: 'porto')

    expect(page.find('[data-mode-toggle="month"]')[:class]).to include('bg-white text-slate-900 shadow-sm')
    expect(page).to have_link(I18n.t('history.index.mode.twelve_months'),
                              href: '/history?categories%5B%5D=insurance&q=porto&range=12m&types%5B%5D=expenses')
  end

  it 'marks the twelve month mode and links back to the current month without the range' do
    page = render_toggle(History::Slice.new(categories: %w[insurance], range: '12m'))

    expect(page.find('[data-mode-toggle="twelve_months"]')[:class]).to include('bg-white text-slate-900 shadow-sm')
    expect(page).to have_link(I18n.t('history.index.mode.month'),
                              href: '/history?categories%5B%5D=insurance&month=5&types%5B%5D=expenses&year=2026')
  end
end
