require 'rails_helper'

RSpec.describe 'Analysis', type: :system, js: true do
  let(:current_user) { create(:user) }

  before do
    travel_to Time.zone.local(2026, 5, 20, 10, 0)

    vehicle = create(:vehicle, user: current_user)

    [[3, 10_000, 10_500], [4, 11_000, 11_500], [5, 12_000, 12_500]].each do |month, first_odometer, second_odometer|
      create(:earning, user: current_user, amount: 1000, trips_count: 10, date: Date.new(2026, month, 10))
      create(:expense, user: current_user, category: :fuel, amount: 200, date: Date.new(2026, month, 10))
      create(:refueling, vehicle: vehicle, odometer_km: first_odometer, date: Date.new(2026, month, 1))
      create(:refueling, vehicle: vehicle, odometer_km: second_odometer, date: Date.new(2026, month, 15))
    end

    login_as(current_user)
  end

  def card_box(label)
    find('span', text: label, exact_text: true).evaluate_script("this.closest('div:has(> p)').getBoundingClientRect().toJSON()")
  end

  it 'starts the analysis title below the iOS status bar on a phone' do
    visit analysis_path

    title = find('h1', text: I18n.t('analysis.show_view.title'))

    expect(computed('turbo-frame#page', 'paddingTop')).to eq('16px')
    expect(title.evaluate_script('this.getBoundingClientRect().top').round).to eq(24)
    expect(page).to fit_the_phone_width
  end

  it 'keeps the Analysis header still while the metrics scroll on a phone' do
    emulate_short_phone

    visit analysis_path(year: 2026, month: 5)

    expect(find('h1', text: I18n.t('analysis.show_view.title'))).to stay_pinned_while_the_content_scrolls
    expect(page).to fit_the_phone_width
  end

  it 'puts the per km hero on top, two compact cards side by side and Sobra across the row on a phone' do
    visit analysis_path

    hero = card_box(I18n.t('analysis.show_view.metrics.per_km_hero'))
    per_day = card_box(I18n.t('analysis.show_view.metrics.per_day'))
    per_trip = card_box(I18n.t('analysis.show_view.metrics.per_trip'))
    margin = card_box(I18n.t('analysis.show_view.metrics.margin'))

    expect(page).to have_text('R$ 0,96')
    expect(per_day['y'].round).to eq(per_trip['y'].round)
    expect(per_trip['x']).to be > per_day['x']
    expect(hero['y']).to be < per_day['y']
    expect(margin['y']).to be > per_day['y']
    expect(margin['width']).to be_within(0.5).of(hero['width'])
    expect(page).to fit_the_phone_width
  end

  it 'lays the four metric cards in one row with a wider hero on a desktop screen' do
    emulate_desktop_screen

    visit analysis_path

    hero = card_box(I18n.t('analysis.show_view.metrics.per_km_hero'))
    per_day = card_box(I18n.t('analysis.show_view.metrics.per_day'))
    per_trip = card_box(I18n.t('analysis.show_view.metrics.per_trip'))
    margin = card_box(I18n.t('analysis.show_view.metrics.margin'))

    expect([hero['y'], per_day['y'], per_trip['y'], margin['y']].map(&:round).uniq.size).to eq(1)
    expect(hero['width']).to be > per_day['width']
    expect(per_day['x']).to be < per_trip['x']
    expect(per_trip['x']).to be < margin['x']
  end

  it 'keeps the prototype gutter, thin bars and no platform donut on a phone in dark mode' do
    emulate_color_scheme('dark')

    visit analysis_path

    title = find('h1', text: I18n.t('analysis.show_view.title'))
    earnings_bar = first('.rounded-t.bg-emerald-500')

    expect(title.evaluate_script('this.getBoundingClientRect().x').round).to eq(20)
    expect(earnings_bar.evaluate_script('this.getBoundingClientRect().width').round).to eq(5)
    expect(page).to have_no_css('#platform_breakdown', visible: true)
    expect(page).to fit_the_phone_width
  end

  it 'leaves the months after today out of the tab order and without a tooltip' do
    visit analysis_path

    future = first('[data-future="true"]', visible: :all)
    past = find('[data-bar-tooltip-target="column"]', text: 'Mai')

    expect(future['tabindex']).to be_nil
    expect(future['role']).to be_nil
    expect(past['tabindex']).to eq('0')
  end

  it 'shows the column tooltip on keyboard focus and hides it on blur on a phone' do
    visit analysis_path

    may = find('[data-bar-tooltip-target="column"]', text: 'Mai')
    may.execute_script('this.focus()')

    expect(page).to have_css('[data-bar-tooltip-target="tooltip"]', visible: true, text: /mai/i)
    expect(page).to have_css('[data-bar-tooltip-target="earnValue"]', text: 'R$ 1.000,00')

    may.execute_script('this.blur()')

    expect(page).to have_no_css('[data-bar-tooltip-target="tooltip"]', visible: true)
    expect(page).to fit_the_phone_width
  end

  it 'shows the white topbar with the export shortcut and the platform donut beside the categories on a desktop screen' do
    emulate_desktop_screen

    visit analysis_path

    topbar = find('h1', text: I18n.t('analysis.show_view.title')).find(:xpath, 'ancestor::div[contains(@class, "lg:bg-white")][1]')
    categories = find('h3', text: I18n.t('analysis.show_view.categories.title')).find(:xpath, '..')
    platforms = find('#platform_breakdown section')

    expect(topbar.evaluate_script('getComputedStyle(this).backgroundColor')).to eq('rgb(255, 255, 255)')
    expect(page).to have_link(I18n.t('analysis.show_view.export'), href: exports_path)
    expect(platforms.evaluate_script('this.getBoundingClientRect().height')).to eq(categories.evaluate_script('this.getBoundingClientRect().height'))
  end

  it 'opens the history filtered by the insight category and month from the insight link on a desktop screen' do
    emulate_desktop_screen
    visit analysis_path(year: 2026, month: 5)

    click_link I18n.t('analysis.show_view.insights.category_share.link')

    expect(page).to have_current_path(history_path(filter: 'fuel', year: 2026, month: 5))
    expect(page).to have_css('a.bg-slate-800', text: I18n.t('activerecord.attributes.expense.categories.fuel'), exact_text: true)
    expect(page).to have_css('tbody tr', count: 1)
  end

  it 'switches the year inside the period popover, keeps it open and picks a month on a phone' do
    create(:earning, user: current_user, amount: 500, date: Date.new(2025, 11, 10))
    travel_to Time.zone.local(2026, 6, 3, 10, 0)

    visit analysis_path
    click_button I18n.t('filter_component.title')
    panel = find('[data-filter-popover-target="panel"]')

    expect(panel).to have_link('Jun')
    expect(panel).to have_no_link('Jul')
    expect(panel).to have_no_link('Jan')

    panel.click_link I18n.t('filter_component.previous_year')
    reopened = find('[data-filter-popover-target="panel"]')

    expect(page).to have_current_path(analysis_path(year: 2025))
    expect(reopened).to have_css('p', text: '2025', exact_text: true)
    expect(reopened).to have_css('a.bg-blue-50', text: I18n.t('filter_component.all_months'))
    expect(reopened).to have_link(I18n.t('filter_component.next_year'))

    reopened.click_link 'Nov'

    expect(page).to have_current_path(analysis_path(year: 2025, month: 11))
    expect(page).to have_text(I18n.t('analysis.show_view.subtitle_monthly', month_name: 'Novembro', year: 2025))
    expect(page).to fit_the_phone_width
  end

  it 'replaces the year pill with one period pill that switches the year inside its popover on a desktop screen' do
    create(:earning, user: current_user, amount: 500, date: Date.new(2025, 11, 10))
    emulate_desktop_screen

    visit analysis_path(year: 2026, month: 5)

    expect(page).to have_no_select('year')

    click_button 'Maio 2026'
    find('[data-filter-popover-target="panel"]').click_link I18n.t('filter_component.previous_year')

    expect(page).to have_button(I18n.t('filter_component.year_all_months', year: 2025))

    find('[data-filter-popover-target="panel"]').click_link 'Nov'

    expect(page).to have_current_path(analysis_path(year: 2025, month: 11))
    expect(page).to have_button('Novembro 2025')
  end

  it 'keeps the category insight without the history link on a phone' do
    visit analysis_path(year: 2026, month: 5)

    expect(page).to have_text('Combustível leva')
    expect(page).to have_no_link(I18n.t('analysis.show_view.insights.category_share.link'))
    expect(page).to fit_the_phone_width
  end

  it 'shows the dimmed chart frame and the empty block for a month without records on a phone' do
    visit analysis_path(year: 2026, month: 6)

    expect(page).to have_text(I18n.t('analysis.show_view.empty_chart_title'))
    expect(page).to have_text(I18n.t('empty_states.analysis.title', period: 'junho'))
    expect(page).to have_link(I18n.t('empty_states.analysis.cta'))
    expect(page).to have_link('Ver maio, o último mês com dados →', href: analysis_path(year: 2026, month: 5))
    expect(page).to fit_the_phone_width
  end

  it 'gives the last-month shortcut a 44px touch target without moving its text on a phone' do
    visit analysis_path(year: 2026, month: 6)

    cta = find(:link, I18n.t('empty_states.analysis.cta')).evaluate_script('this.getBoundingClientRect().toJSON()')
    shortcut = find(:link, 'Ver maio, o último mês com dados →')
    target = shortcut.evaluate_script('this.getBoundingClientRect().toJSON()')
    text_top = shortcut.evaluate_script(<<~JS)
      (() => { const range = document.createRange(); range.selectNodeContents(this); return range.getBoundingClientRect().top })()
    JS

    expect(target['height']).to be >= 44
    expect(target['top']).to be >= cta['bottom']
    expect(text_top - cta['bottom']).to be_within(1).of(12)
  end
end
