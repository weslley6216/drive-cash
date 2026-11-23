require 'rails_helper'

RSpec.describe 'History filters', type: :system, js: true do
  let(:current_user) { create(:user) }

  before do
    travel_to Time.zone.local(2026, 5, 22, 10, 0)
    create(:earning, user: current_user, date: Date.new(2026, 5, 22), amount: 32.5, platform: 'uber', trips_count: 1)
    create(:earning, user: current_user, date: Date.new(2026, 5, 21), amount: 41.5, platform: 'nine_nine', trips_count: 1)
    create(:expense, user: current_user, date: Date.new(2026, 5, 22), amount: 60, category: 'fuel', vendor: 'Posto Orense', paid: true)
    create(:expense, user: current_user, date: Date.new(2026, 5, 19), amount: 65, category: 'fuel', vendor: 'Posto Orense', paid: true)
    create(:expense, user: current_user, date: Date.new(2026, 5, 18), amount: 70, category: 'fuel', vendor: 'Shell Av. Brasil', paid: true)
    create(:expense, user: current_user, date: Date.new(2026, 5, 20), amount: 35, category: 'car_wash', vendor: 'Lava-rápido Central', paid: false)
    create(:expense, user: current_user, date: Date.new(2026, 4, 16), amount: 100, category: 'fuel', vendor: 'Posto Orense', paid: true)
    login_as(current_user)
  end

  let(:panel) { find('[data-history-filter-panel-target="panel"]') }

  it 'narrows the history down to one station from the side panel, counting live, on a phone' do
    visit history_path(year: 2026, month: 5)
    click_button I18n.t('history.index.filters.button')

    panel.check(I18n.t('history.index.panel.expenses'), allow_label_click: true)
    expect(panel).to have_button(I18n.t('history.index.panel.submit', count: 4))
    panel.check('Combustível', allow_label_click: true)
    expect(panel).to have_button(I18n.t('history.index.panel.submit', count: 3))
    panel.check('Posto Orense', allow_label_click: true)
    expect(page).to fit_the_phone_width

    panel.click_button I18n.t('history.index.panel.submit', count: 2)

    expect(page).to have_button(I18n.t('history.index.filters.button_count', count: 2))
    expect(page.all('[data-slice-pill]').map(&:text)).to eq(['Combustível', 'Posto Orense'])
    expect(page).to have_css('#day-2026-05-22')
    expect(page).to have_css('#day-2026-05-19')
    expect(page).to have_no_text('Shell Av. Brasil')
    expect(page).to have_no_text('+R$ 32,50')
    expect(page).to fit_the_phone_width
  end

  it 'locks the submit when the marked combination has no records on a phone' do
    visit history_path(year: 2026, month: 5)
    click_button I18n.t('history.index.filters.button')
    panel.check(I18n.t('history.index.panel.expenses'), allow_label_click: true)
    panel.check(I18n.t('history.index.panel.unpaid_only'), allow_label_click: true)
    panel.check('Combustível', allow_label_click: true)

    expect(panel).to have_button(I18n.t('history.index.panel.submit_none'), disabled: true)
    expect(page).to fit_the_phone_width
  end

  it 'discards the marks when the panel closes and clears them without closing on a phone' do
    visit history_path(year: 2026, month: 5)
    click_button I18n.t('history.index.filters.button')
    panel.check(I18n.t('history.index.panel.earnings'), allow_label_click: true)
    panel.find("button[aria-label='#{I18n.t('history.index.panel.close')}']").click
    click_button I18n.t('history.index.filters.button')

    expect(panel).to have_unchecked_field(I18n.t('history.index.panel.earnings'), visible: :all)

    panel.check(I18n.t('history.index.panel.earnings'), allow_label_click: true)
    panel.click_button I18n.t('history.index.panel.clear')

    expect(panel).to have_unchecked_field(I18n.t('history.index.panel.earnings'), visible: :all)
    expect(panel).to have_button(I18n.t('history.index.panel.submit_all', count: 6))
  end

  it 'drops the category with its station from the pill cross on a phone' do
    visit history_path(year: 2026, month: 5, categories: %w[fuel], vendors: { fuel: ['Posto Orense'] })
    find("a[aria-label='#{I18n.t('history.index.trail.remove', label: 'Combustível')}']").click

    expect(page).to have_css('a.bg-slate-800', text: I18n.t('history.index.filters.expenses'), exact_text: true)
    expect(page).to have_text('Lava-rápido Central')
    expect(page).to fit_the_phone_width
  end

  it 'gives the filters button and the pill controls a touch target of at least 44px on a phone' do
    visit history_path(year: 2026, month: 5, categories: %w[fuel], vendors: { fuel: ['Posto Orense'] })
    button = find('button', text: I18n.t('history.index.filters.button_count', count: 2))
    remove = find("a[aria-label='#{I18n.t('history.index.trail.remove', label: 'Combustível')}']")
    reopen = find('[data-slice-pill="categories"] button')

    tapped = button.evaluate_script('(() => { const rect = this.getBoundingClientRect(); return document.elementFromPoint(rect.left + 10, rect.top - 7).closest("button") === this })()')

    expect(tapped).to be(true)
    expect(box(remove)['height']).to be >= 44
    expect(box(reopen)['height']).to be >= 44
    expect(box(button)['height'].round).to eq(28)
    expect(page).to fit_the_phone_width
  end

  it 'reopens the panel with the marks of the slice from the pill body on a phone' do
    visit history_path(year: 2026, month: 5, categories: %w[fuel], vendors: { fuel: ['Posto Orense'] })
    find('[data-slice-pill="vendors"] button').click

    expect(panel).to have_checked_field('Posto Orense', visible: :all)
    expect(panel).to have_button(I18n.t('history.index.panel.submit', count: 2))
  end

  it 'sums up the stations in the group subtitle and collapses them to the marked names on a phone' do
    visit history_path(year: 2026, month: 5)
    click_button I18n.t('history.index.filters.button')
    panel.check(I18n.t('history.index.panel.expenses'), allow_label_click: true)
    panel.check('Combustível', allow_label_click: true)
    vendors = panel.find('[data-level="vendors"]')

    expect(vendors).to have_text(I18n.t('history.index.panel.vendors_all', categories: 'Combustível'))

    panel.check('Posto Orense', allow_label_click: true)
    expect(vendors).to have_text(I18n.t('history.index.panel.vendors_marked', count: 1))
    vendors.find('button', text: I18n.t('history.index.panel.vendors')).click

    expect(vendors).to have_css('[data-group="vendors"]', text: 'Posto Orense', exact_text: true)
    expect(vendors).to have_no_css('label', text: 'Shell Av. Brasil')
    expect(page).to have_no_text(I18n.t('history.index.panel.vendors').upcase)
  end

  it 'forgets the stations and their count once expenses are unmarked on a phone' do
    visit history_path(year: 2026, month: 5)
    click_button I18n.t('history.index.filters.button')
    panel.check(I18n.t('history.index.panel.expenses'), allow_label_click: true)
    panel.check('Combustível', allow_label_click: true)
    panel.check('Posto Orense', allow_label_click: true)

    panel.uncheck(I18n.t('history.index.panel.expenses'), allow_label_click: true)

    expect(panel).to have_button(I18n.t('history.index.panel.submit_all', count: 6))
    expect(panel).to have_no_css('[data-level="vendors"] label', text: 'Posto Orense')
  end

  it 'searches the stations once there are more than six on a phone' do
    %w[Ale BR Ipiranga Petrobras Raízen Texaco].each do |name|
      create(:expense, user: current_user, date: Date.new(2026, 5, 10), amount: 50, category: 'fuel', vendor: name)
    end

    visit history_path(year: 2026, month: 5)
    click_button I18n.t('history.index.filters.button')
    panel.check(I18n.t('history.index.panel.expenses'), allow_label_click: true)
    panel.check('Combustível', allow_label_click: true)
    panel.fill_in placeholder: I18n.t('history.index.panel.vendor_search'), with: 'ipi'

    expect(panel).to have_css('label', text: 'Ipiranga')
    expect(panel).to have_no_css('label', text: 'Texaco')
    expect(page).to fit_the_phone_width
  end

  it 'opens the three column popover under the filters button and applies a mixed slice on a desktop screen' do
    emulate_desktop_screen
    visit history_path(year: 2026, month: 5)
    click_button I18n.t('history.index.filters.button')

    expect(box(panel.find('[data-history-filter-panel-target="sheet"]'))['width'].round).to eq(820)

    panel.check(I18n.t('history.index.panel.earnings'), allow_label_click: true)
    panel.check('Uber', allow_label_click: true)
    panel.check(I18n.t('history.index.panel.expenses'), allow_label_click: true)
    panel.check('Lavagem', allow_label_click: true)

    expect(panel).to have_text(I18n.t('history.index.panel.platforms_and_categories').upcase)

    panel.click_button I18n.t('history.index.panel.submit', count: 2)

    expect(page).to have_css('tbody tr', count: 2)
    expect(page).to have_text('2 lançamentos · maio 2026')
    expect(page).to have_link(I18n.t('history.index.filters.clear'))
  end

  it 'keeps the popover on screen, scrolling the categories inside it, with no platform for expenses on a desktop screen' do
    emulate_desktop_screen
    visit history_path(year: 2026, month: 5)
    click_button I18n.t('history.index.filters.button')

    expect(panel).to have_text(I18n.t('history.index.panel.empty_types'))
    expect(panel).to have_text(I18n.t('history.index.panel.empty_vendors_type'))

    panel.check(I18n.t('history.index.panel.expenses'), allow_label_click: true)
    sheet = panel.find('[data-history-filter-panel-target="sheet"]')

    expect(panel).to have_css('label', text: 'Combustível')
    expect(panel).to have_no_css('label', text: 'Uber')
    expect(panel).to have_text(I18n.t('history.index.panel.empty_vendors_category'))
    expect(box(sheet)['right']).to be <= 1280
    expect(box(sheet)['left'].round).to eq(box(find('input[type="search"][name="q"]'))['left'].round)
    expect(box(panel.find('button[type="submit"]'))['bottom']).to be <= box(sheet)['bottom']
  end

  it 'sums the station slice with its six month band and counts the records in the subtitle on a phone' do
    visit history_path(year: 2026, month: 5, categories: %w[fuel], vendors: { fuel: ['Posto Orense'] })

    within('[data-slice-summary="tiles"]') do
      expect(page).to have_text('R$ 125,00')
      expect(page).to have_text(I18n.t('history.index.slice_summary.refuelings').upcase)
      expect(page).to have_text('R$ 62,50')
    end
    expect(page).to have_text(I18n.t('history.index.count_subtitle', count: 2, period: 'maio 2026'))
    expect(page).to have_css('[data-trend-bar]', count: 6)
    expect(box(all('[data-trend-bar]').last)['height'].round).to eq(56)
    expect((box(find('[data-slice-summary="tiles"]'))['top'] - box(find('[data-slice-summary="trend"]'))['bottom']).round).to eq(16)
    expect(page).to have_text("+25% #{I18n.t('history.index.slice_summary.versus', month: 'abril')}")
    expect(page).to have_no_text(I18n.t('history.index.summary.net').upcase)
    expect(page).to have_no_text(I18n.t('history.index.slice_summary.no_trend_hint'))
    expect(page).to fit_the_phone_width
  end

  it 'shows the pending tile and no band for a slice of two categories on a phone' do
    visit history_path(year: 2026, month: 5, categories: %w[fuel car_wash])

    within('[data-slice-summary="tiles"]') do
      expect(page).to have_text(I18n.t('history.index.slice_summary.pending').upcase)
      expect(page).to have_text('R$ 35,00')
    end
    expect(page).to have_no_css('[data-slice-summary="trend"]')
    expect(page).to have_text(I18n.t('history.index.slice_summary.no_trend_hint'))
    expect((box(find('p', text: I18n.t('history.index.slice_summary.no_trend_hint')))['top'] - box(find('[data-slice-summary="tiles"]'))['bottom']).round).to eq(16)
    expect(page).to fit_the_phone_width
  end

  it 'puts the slice tiles beside the six month band on a desktop screen' do
    emulate_desktop_screen
    visit history_path(year: 2026, month: 5, categories: %w[fuel])

    tiles = find('[data-slice-summary="tiles"]')
    band = find('[data-slice-summary="trend"]')

    expect(box(band)['left']).to be > box(tiles)['right']
    expect(box(band)['top'].round).to eq(box(tiles)['top'].round)
    expect(box(band.all('[data-trend-bar]').last)['height'].round).to eq(40)
    expect(box(band.find('[data-trend-change]').find(:xpath, '..'))['top'].round).to eq(box(band.find('p', text: I18n.t('history.index.slice_summary.trend_title.expenses').upcase))['top'].round)
  end

  it 'keeps the slice when the month has nothing in it and offers to clear it on a phone' do
    visit history_path(year: 2026, month: 3, categories: %w[fuel], vendors: { fuel: ['Posto Orense'] })

    expect(page).to have_text(I18n.t('empty_states.history.slice.title_month', month: 'março'))
    expect(page).to have_text(I18n.t('empty_states.history.slice.description', slice: 'Combustível (Posto Orense)', period: 'março de 2026'))
    expect(page).to have_css('[data-slice-pill="categories"]', text: 'Combustível')
    expect(page).to have_link(I18n.t('empty_states.history.cta'), href: history_path(year: 2026, month: 3))
    expect(page).to fit_the_phone_width
  end
end
