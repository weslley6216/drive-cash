require 'rails_helper'

RSpec.describe 'Edit record', type: :system, js: true do
  let(:current_user) { create(:user) }

  before do
    travel_to Time.zone.local(2026, 5, 22, 10, 0)
    login_as(current_user)
  end

  it 'opens the earning from the history as the full screen record form, prefilled and themed, on a phone' do
    create(:earning, user: current_user, date: Date.new(2026, 5, 20), amount: 120, platform: 'uber', trips_count: 3)
    visit history_path

    find("a[aria-label='#{I18n.t('history.index.edit.earning')}']", match: :first).click

    screen = find('turbo-frame#modal > div')

    expect(page).to have_css('p', text: I18n.t('records.edit_view.title'))
    expect(find('[data-record-form-target="amountDisplay"]').value).to eq('120,00')
    expect(find('[data-record-form-target="amountDisplay"]')[:class]).to include('text-emerald-700')
    expect(page).to have_no_css('[data-record-form-target="earningToggle"]')
    expect(box(screen)['y'].round).to eq(0)
    expect(box(screen)['height'].round).to eq(844)
    expect(page).to fit_the_phone_width
  end

  it 'saves the edited earning and lands on the month detail on a phone' do
    earning = create(:earning, user: current_user, date: Date.new(2026, 5, 20), amount: 120, platform: 'uber', trips_count: 3)
    visit history_path
    find("a[aria-label='#{I18n.t('history.index.edit.earning')}']", match: :first).click

    click_on '+'
    click_on I18n.t('records.new_view.save_earning')

    expect(page).to have_text(I18n.t('dashboard.earnings_detail_view.title_month'))
    expect(earning.reload.trips_count).to eq(4)
  end

  it 'opens the expense from the history as the centered record modal on a desktop screen' do
    emulate_desktop_screen
    create(:expense, user: current_user, date: Date.new(2026, 5, 20), amount: 80, category: 'maintenance', paid: false)
    visit history_path

    find("a[aria-label='#{I18n.t('history.index.edit.expense')}']", match: :first).click

    card = find('h2', text: I18n.t('records.edit_view.title')).find(:xpath, 'ancestor::div[contains(@class, "group/record")][1]')
    amount_box = find('[data-record-form-target="amountTheme"]')
    card_box = box(card)

    expect(card_box['x'] + (card_box['width'] / 2)).to be_within(1).of(640)
    expect(card_box['width'].round).to eq(672)
    expect(amount_box.evaluate_script('getComputedStyle(this).backgroundColor')).to eq('rgb(254, 242, 242)')
    expect(find('input[type="checkbox"][name="record[paid]"]', visible: :all)).not_to be_checked
    expect(page).to have_no_text(I18n.t('records.new_view.recurring_toggle.title'))
  end

  it 'closes the desktop modal from cancel and stays on the history' do
    emulate_desktop_screen
    create(:expense, user: current_user, date: Date.new(2026, 5, 20), amount: 80, category: 'maintenance')
    visit history_path
    find("a[aria-label='#{I18n.t('history.index.edit.expense')}']", match: :first).click

    click_on I18n.t('records.new_view.cancel')

    expect(page).to have_no_css('h2', text: I18n.t('records.edit_view.title'))
    expect(page).to have_current_path(history_path)
  end
end
