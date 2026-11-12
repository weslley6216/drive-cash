require 'rails_helper'

RSpec.describe 'History', type: :system, js: true do
  let(:current_user) { create(:user) }

  before do
    travel_to Time.zone.local(2026, 5, 22, 10, 0)
    create(:earning, user: current_user, date: Date.new(2026, 5, 22), amount: 32.5, platform: 'uber', trips_count: 1)
    create(:expense, user: current_user, date: Date.new(2026, 5, 21), amount: 10_450, category: 'maintenance',
                     description: 'Retífica do motor com troca completa de juntas', paid: true)
    login_as(current_user)
  end

  def box(element)
    element.evaluate_script('this.getBoundingClientRect().toJSON()')
  end

  it 'starts the history title below the iOS status bar on a phone' do
    visit history_path(year: 2026, month: 5)

    title = find('h1', text: I18n.t('history.index.title'))

    expect(computed('turbo-frame#page', 'paddingTop')).to eq('16px')
    expect(box(title)['top'].round).to eq(24)
    expect(page).to fit_the_phone_width
  end

  it 'lists the day groups with the platform badge and fits a five digit expense on a phone' do
    visit history_path(year: 2026, month: 5)

    badge = find('#day-2026-05-22 div[style*="background-color"]', text: 'Uber')

    expect(box(badge)['width'].round).to eq(40)
    expect(page).to have_text('−R$ 10.450,00')
    expect(page).to have_text("#{I18n.t('common.today')} · 22 mai".upcase)
    expect(page).to fit_the_phone_width
  end

  it 'fits the phone width in dark mode' do
    emulate_color_scheme('dark')

    visit history_path(year: 2026, month: 5)

    expect(page).to have_text('+R$ 32,50')
    expect(page).to fit_the_phone_width
  end

  it 'echoes the search term and keeps a 44px clear button when nothing matches on a phone' do
    visit history_path(year: 2026, month: 5, q: 'posto ipiranga')

    clear = find('a', text: I18n.t('empty_states.history.cta'))

    expect(page).to have_text(I18n.t('empty_states.history.description_query', query: 'posto ipiranga'))
    expect(page).to have_no_text(I18n.t('history.index.summary.net'))
    expect(box(clear)['height']).to be >= 44
    expect(page).to fit_the_phone_width
  end

  it 'shows the records as a table with the design column order and no FAB on a desktop screen' do
    emulate_desktop_screen

    visit history_path(year: 2026, month: 5)

    headers = all('thead th').map(&:text).reject(&:empty?)

    expect(headers).to eq(%w[date type description status amount].map { |column| I18n.t("history.index.table.#{column}").upcase })
    expect(page).to have_css('tbody tr', count: 2)
    expect(page).to have_no_css('[data-controller="fab"]', visible: true)
  end
end
