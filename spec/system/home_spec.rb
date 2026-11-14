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

  it 'truncates large stat values inside the card and keeps the page within the phone width' do
    visit root_path

    expenses_value = find('#stats_grid p', text: 'R$ 10.530,00')
    card = expenses_value.find(:xpath, 'ancestor::a[1]')

    expect(page).to have_css('p', text: I18n.t('dashboard.index_view.eyebrow').upcase)
    expect(box(expenses_value)['right']).to be <= box(card)['right']
    expect(expenses_value.evaluate_script('getComputedStyle(this).textOverflow')).to eq('ellipsis')
    expect(page).to fit_the_phone_width
  end

  it "shows today's net under the Caju card and above the stat cards on a phone" do
    visit root_path

    today = find('#today_card')
    caju = find('a', text: I18n.t('caju_quick_access_component.title'))

    expect(today).to have_text('R$ 165,00')
    expect(today).to have_text('+R$ 245,00')
    expect(today).to have_text('−R$ 80,00')
    expect(today).to have_text('7 corridas')
    expect(box(today)['top']).to be > box(caju)['bottom']
    expect(box(today)['bottom']).to be < box(find('#stats_grid'))['top']
    expect(page).to fit_the_phone_width
  end

  it 'shows the whole revenue at the original phone size on the stat card' do
    create(:earning, user: current_user, date: Date.new(2026, 3, 3), amount: 60_619.20)

    visit root_path

    revenue = find('#stats_grid p', text: 'R$ 65.695,10')

    expect(revenue.evaluate_script('getComputedStyle(this).fontSize')).to eq('20px')
    expect(revenue.evaluate_script('this.scrollWidth <= this.clientWidth')).to be(true)
    expect(page).to fit_the_phone_width
  end

  it 'gives the month chips a 44px tap area while keeping the prototype size in dark mode' do
    emulate_color_scheme('dark')

    visit root_path

    chip = find('a', text: 'Jan', exact_text: true)
    rect = box(chip)
    tap_center = rect['x'] + (rect['width'] / 2)
    top_hit = page.evaluate_script("document.elementFromPoint(#{tap_center}, #{rect['top'] + rect['height'] / 2 - 22 + 1})?.closest('a')?.textContent")
    bottom_hit = page.evaluate_script("document.elementFromPoint(#{tap_center}, #{rect['top'] + rect['height'] / 2 + 22 - 2})?.closest('a')?.textContent")

    expect(chip[:href]).to end_with('month=1&year=2026')
    expect(rect['height']).to be < 44
    expect([top_hit, bottom_hit]).to eq(%w[Jan Jan])
    expect(page).to fit_the_phone_width
  end

  it 'keeps the Home header still while the month chips and the cards scroll on a phone' do
    emulate_short_phone

    visit root_path

    expect(page).to have_css('#screen-content a', text: 'Jan', exact_text: true)
    expect(find('h1', text: 'Olá, Weslley')).to stay_pinned_while_the_content_scrolls
    expect(page).to fit_the_phone_width
  end

  it 'lays the four stat cards in one row under a white topbar on a desktop screen' do
    emulate_desktop_screen(height: 500)

    visit root_path

    cards = all('#stats_grid > *').map { |card| box(card) }
    topbar = find('h1', text: 'Olá, Weslley').find(:xpath, 'ancestor::div[contains(@class, "lg:bg-white")][1]')

    expect(cards.size).to eq(4)
    expect(cards.map { |card| card['y'].round }.uniq.size).to eq(1)
    expect(topbar.evaluate_script('getComputedStyle(this).backgroundColor')).to eq('rgb(255, 255, 255)')
    expect(page).to have_css('#today_card', visible: true)
    expect(box(topbar)['top'].round).to eq(0)
    expect(topbar).to stay_pinned_while_the_content_scrolls
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

  it 'keeps the month chips 13px under the greeting like the prototype on a phone' do
    visit root_path

    greeting = find('h1', text: 'Olá, Weslley')
    chip = find('a', text: I18n.t('filter_component.all_chip'), exact_text: true)

    expect((box(chip)['top'] - box(greeting)['bottom']).round).to eq(13)
    expect(page).to fit_the_phone_width
  end

  it 'lines the stat values up with their titles on a desktop screen' do
    emulate_desktop_screen

    visit root_path

    revenue_card = find('#stats_grid > *', match: :first)
    title = revenue_card.find('p', match: :first)
    value = revenue_card.find('p', text: 'R$ 5.075,90')

    expect(box(value)['x'].round).to eq(box(title)['x'].round)
    expect(box(value)['width'].round).to be <= box(title)['width'].round
  end

  it 'scrolls the strip so the December chip of a past year sits inside it on a phone' do
    create(:earning, user: current_user, date: Date.new(2025, 12, 5), amount: 300)

    visit root_path(year: 2025, month: 12)

    chip = find('a', text: 'Dez', exact_text: true)
    strip = chip.find(:xpath, 'ancestor::div[@data-controller="chip-strip"][1]')
    chip_box = box(chip)
    strip_box = box(strip)

    expect(chip_box['left']).to be >= strip_box['left']
    expect(chip_box['right']).to be <= strip_box['right']
    expect(page).to fit_the_phone_width
  end
end
