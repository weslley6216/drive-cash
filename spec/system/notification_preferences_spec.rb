require 'rails_helper'

RSpec.describe 'Notification preferences', type: :system, js: true do
  let(:user) { create(:user) }

  before do
    travel_to Time.zone.local(2026, 11, 11, 10, 0)
    login_as(user)
  end

  it 'turns a kind off from the Avisos screen on a phone' do
    visit edit_notification_preferences_path
    expect(page).to fit_the_phone_width

    toggle = find(:checkbox, 'Lembrete de registrar', visible: :all)
    toggle.find(:xpath, '..').click

    expect(page).to have_no_checked_field('Lembrete de registrar', visible: :all)
    expect(user.reload.notification_preferences).to eq('log_reminder' => false)
  end

  it 'reaches the Avisos screen from Conta on a phone' do
    visit account_path

    click_on 'Avisos'

    expect(page).to have_current_path(edit_notification_preferences_path)
    expect(page).to have_text(I18n.t('notifications.preferences.mobile_subtitle'))
  end

  it 'shows the breadcrumb on a desktop screen' do
    emulate_desktop_screen

    visit edit_notification_preferences_path

    expect(page).to have_text(I18n.t('notifications.preferences.breadcrumb.account'))
    expect(page).to have_text(I18n.t('notifications.preferences.breadcrumb.notifications'))
    expect(page).to have_text(I18n.t('notifications.preferences.desktop_subtitle'))
    expect(page).to have_no_link(I18n.t('notifications.preferences.back'))
  end
end
