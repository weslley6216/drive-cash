require 'rails_helper'

RSpec.describe 'History twelve months', type: :system, js: true do
  let(:current_user) { create(:user) }

  before do
    travel_to Time.zone.local(2026, 5, 22, 10, 0)
    (0..11).each do |offset|
      create(:expense, user: current_user, date: Date.new(2025, 6, 10) >> offset, amount: offset < 7 ? 189.9 : 214.3,
                       category: 'insurance', vendor: 'Porto Seguro', paid: true)
    end
    login_as(current_user)
  end

  it 'switches one category to twelve months, flags the raise and opens a month back in the month mode on a phone' do
    visit history_path(year: 2026, month: 5, categories: %w[insurance])
    toggle = find('[data-slice-summary="trend"] [data-mode-toggle="twelve_months"]')
    tapped = toggle.evaluate_script('(() => { const rect = this.getBoundingClientRect(); return document.elementFromPoint(rect.left + 10, rect.top - 7).closest("a") === this })()')
    expect(tapped).to be(true)
    toggle.click

    expect(page).to have_text('12 lançamentos · últimos 12 meses')
    within('[data-twelve-months="card"]') do
      expect(page).to have_text('R$ 2.400,80')
      expect(page).to have_text('em 12 meses · média R$ 200,07/mês')
      expect(page).to have_css('[data-twelve-months="adjustment"]', text: 'Reajuste +12,8% em jan')
      expect(page).to have_css('[data-trend-bar]', count: 12)
    end
    expect(box(all('[data-trend-bar]').last)['height'].round).to eq(64)
    expect(page).to have_css('[data-month-row="phone"]', count: 12)
    expect(page).to have_no_css('[data-slice-summary="tiles"]')
    expect(page).to fit_the_phone_width

    find('[data-month-row="phone"]', text: 'Janeiro 2026').click

    expect(page).to have_css('[data-slice-pill="categories"]', text: 'Seguro')
    expect(page).to have_text(I18n.t('history.index.count_subtitle', count: 1, period: 'janeiro 2026'))
    expect(page).to have_css('[data-slice-summary="tiles"]')
  end

  it 'ends the chip bar with the toggle, adds the levels to the badge and lists the months in a table on a desktop screen' do
    emulate_desktop_screen
    visit history_path(categories: %w[insurance], range: '12m')

    expect(page).to have_button(text: I18n.t('filter_component.last_twelve_months'))
    expect(page).to have_css('[data-twelve-months="adjustment"]', text: 'Reajuste +12,8% em jan · R$ 189,90 → R$ 214,30')
    expect(box(all('[data-trend-bar]').last)['height'].round).to eq(80)
    expect(box(find('[data-twelve-months="adjustment"]'))['top']).to be > box(find('[data-twelve-months="total"]'))['bottom']
    expect(box(find('[data-mode-toggle="month"]'))['left']).to be > box(find('[data-slice-pill="categories"]'))['right']
    expect(box(find('[data-mode-toggle="twelve_months"]'))['right'].round).to eq(box(find('[data-twelve-months="card"]'))['right'].round)
    expect(page).to have_css('[data-month-row="desktop"]', count: 12)

    click_link I18n.t('history.index.mode.month')

    expect(page).to have_text(I18n.t('history.index.count_subtitle', count: 1, period: 'maio 2026'))
  end

  it 'offers the last twelve months from an empty month of one category and explains an empty window on a phone' do
    visit history_path(year: 2026, month: 5, categories: %w[documentation])
    click_link I18n.t('empty_states.history.slice.cta_twelve_months')

    expect(page).to have_text(I18n.t('empty_states.history.twelve_months.title'))
    expect(page).to have_link(I18n.t('empty_states.history.cta'))
    expect(page).to fit_the_phone_width
  end
end
