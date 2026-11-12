require 'rails_helper'

RSpec.describe 'Home', type: :system, js: true do
  let(:current_user) { create(:user, name: 'Weslley Campos') }

  before do
    travel_to Time.zone.local(2026, 5, 22, 10, 0)
    create(:earning, user: current_user, date: Date.new(2026, 5, 22), amount: 245, platform: 'uber', trips_count: 7)
    create(:earning, user: current_user, date: Date.new(2026, 1, 12), amount: 4830.90, platform: 'nine_nine', trips_count: 21)
    create(:expense, user: current_user, date: Date.new(2026, 1, 10), amount: 10_450, category: 'maintenance')
    create(:expense, user: current_user, date: Date.new(2026, 5, 22), amount: 80, category: 'fuel', vendor: 'Posto Orense')
    login_as(current_user)
  end

  def box(element)
    element.evaluate_script('this.getBoundingClientRect().toJSON()')
  end

  it 'truncates large stat values inside the card and keeps the page within the phone width' do
    visit root_path

    expenses_value = find('#stats_grid p', text: 'R$ 10.530,00')
    card = expenses_value.find(:xpath, 'ancestor::a[1]')

    expect(page).to have_css('p', text: I18n.t('dashboard.index_view.eyebrow').upcase)
    expect(box(expenses_value)['right']).to be <= box(card)['right']
    expect(expenses_value.evaluate_script('getComputedStyle(this).textOverflow')).to eq('ellipsis')
    expect(page).to have_no_css('#today_card', visible: true)
    expect(page).to fit_the_phone_width
  end

  it 'gives the month chips a 44px tap area while keeping the prototype size in dark mode' do
    emulate_color_scheme('dark')

    visit root_path

    chip = find('a', text: 'Jan', exact_text: true)
    rect = box(chip.find('span'))
    tap_center = rect['x'] + (rect['width'] / 2)
    top_hit = page.evaluate_script("document.elementFromPoint(#{tap_center}, #{rect['top'] + rect['height'] / 2 - 22 + 1})?.textContent")
    bottom_hit = page.evaluate_script("document.elementFromPoint(#{tap_center}, #{rect['top'] + rect['height'] / 2 + 22 - 1})?.textContent")

    expect(chip[:href]).to end_with('month=1&year=2026')
    expect(rect['height']).to be < 44
    expect([top_hit, bottom_hit]).to eq(%w[Jan Jan])
    expect(page).to fit_the_phone_width
  end

  it 'lays the four stat cards in one row under a white topbar on a desktop screen' do
    emulate_desktop_screen

    visit root_path

    cards = all('#stats_grid > *').map { |card| box(card) }
    topbar = find('h1', text: 'Olá, Weslley').find(:xpath, 'ancestor::div[contains(@class, "lg:bg-white")][1]')

    expect(cards.size).to eq(4)
    expect(cards.map { |card| card['y'].round }.uniq.size).to eq(1)
    expect(topbar.evaluate_script('getComputedStyle(this).backgroundColor')).to eq('rgb(255, 255, 255)')
    expect(page).to have_css('#today_card', visible: true)
  end

  it 'shows the first-use empty state without the period filter on a phone' do
    current_user.earnings.delete_all
    current_user.expenses.delete_all

    visit root_path

    expect(page).to have_text(I18n.t('empty_states.home.title'))
    expect(page).to have_link(I18n.t('empty_states.home.cta'))
    expect(page).to have_link(I18n.t('empty_states.home.secondary'), href: chat_root_path)
    expect(page).to have_no_link(I18n.t('filter_component.all_chip'))
    expect(page).to fit_the_phone_width
  end
end
