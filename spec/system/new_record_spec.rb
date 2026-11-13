require 'rails_helper'

RSpec.describe 'New record', type: :system, js: true do
  let(:current_user) { create(:user) }

  before do
    travel_to Time.zone.local(2026, 5, 22, 10, 0)
    login_as(current_user)
  end

  it 'shows the expense form with a compact date and 44px category chips on a phone' do
    visit new_record_path(type: 'expense')

    chip = find('label', text: I18n.t('activerecord.attributes.expense.categories.fuel'))
    amount = find('[data-record-form-target="amountDisplay"]')

    expect(page).to have_text("#{I18n.t('records.new_view.today')} · 22 mai 2026", normalize_ws: true)
    expect(box(chip)['height']).to be >= 44
    expect(computed('[data-record-form-target="amountDisplay"]', 'fontSize')).to eq('60px')
    expect(box(amount)['height'].round).to eq(60)
    expect(page).to have_text(I18n.t('records.new_view.recurring_toggle.subtitle'))
    expect(page).to fit_the_phone_width
  end

  it 'shows the earning form with 44px platform chips in dark mode on a phone' do
    emulate_color_scheme('dark')

    visit new_record_path(type: 'earning')

    chip = find('label', text: I18n.t('activerecord.attributes.earning.platforms.uber'), match: :first)

    expect(box(chip)['height']).to be >= 44
    expect(page).to have_text(I18n.t('activerecord.attributes.earning.platforms.other'))
    expect(page).to fit_the_phone_width
  end

  it 'updates the date label when another day is picked' do
    visit new_record_path(type: 'expense')

    find('input[name="record[date]"]', visible: :all).set('2026-05-18')

    expect(page).to have_text('Segunda-feira · 18 mai 2026', normalize_ws: true)
  end

  it 'starts the new record top bar below the iOS status bar on a phone' do
    visit new_record_path(type: 'expense')

    close = find("a[aria-label='#{I18n.t('records.new_view.close')}']")

    expect(computed('.safe-top', 'paddingTop')).to eq('16px')
    expect(box(close)['top'].round).to eq(24)
    expect(page).to fit_the_phone_width
  end

  it 'centers the form as a modal with the amount and date side by side on a desktop screen' do
    emulate_desktop_screen

    visit new_record_path(type: 'expense')

    card = find('h2', text: I18n.t('records.new_view.title')).find(:xpath, 'ancestor::div[contains(@class, "group/record")][1]')
    amount_box = find('[data-record-form-target="amountTheme"]')
    date_box = find('[data-record-form-target="dateText"]').find(:xpath, '..')
    card_box = box(card)

    expect(card_box['x'] + (card_box['width'] / 2)).to be_within(1).of(640)
    expect(card_box['width'].round).to eq(672)
    expect(box(amount_box)['y'].round).to eq(box(date_box)['y'].round)
    expect(amount_box.evaluate_script('getComputedStyle(this).backgroundColor')).to eq('rgb(254, 242, 242)')
    expect(computed('.safe-top', 'paddingTop')).to eq('32px')
    expect(page).to have_link(I18n.t('records.new_view.cancel'), href: root_path)
  end

  it 'opens the new record page from the history topbar on a desktop screen' do
    emulate_desktop_screen
    visit history_path

    click_on I18n.t('history.index.new_record')

    expect(page).to have_current_path(new_record_path)
    expect(page).to have_css('h2', text: I18n.t('records.new_view.title'))
  end
end
