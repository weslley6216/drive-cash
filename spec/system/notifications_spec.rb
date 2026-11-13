require 'rails_helper'

RSpec.describe 'Notifications', type: :system, js: true do
  let(:current_user) { create(:user) }

  before do
    travel_to Time.zone.local(2026, 11, 11, 10, 0)

    @vehicle = create(:vehicle, user: current_user, odometer_km: 160_928)
    @oil = create(:maintenance, vehicle: @vehicle, category: 'oil_change', last_done_km: 160_928, interval_km: 5_000)

    login_as(current_user)
  end

  it "opens yesterday's record from a log reminder on a phone" do
    notification = create(:notification, user: current_user, kind: 'log_reminder', data: { 'date' => '2026-11-11' })

    visit notifications_path
    expect(page).to fit_the_phone_width

    click_on I18n.t('notifications.kinds.log_reminder.title')

    expect(page).to have_current_path('/records/new?date=2026-11-10')
    expect(page).to have_field('record[date]', with: '2026-11-10', visible: :all)
    expect(page).to have_text('10 nov 2026')
    expect(notification.reload.read_at).to be_present
  end

  it 'keeps the notifications header still while the list scrolls on a phone' do
    (1..6).each do |day|
      create(:notification, user: current_user, kind: 'log_reminder', data: { 'date' => Date.new(2026, 11, day).to_s })
    end
    emulate_short_phone

    visit notifications_path

    expect(find('h1', text: I18n.t('notifications.index.title'))).to stay_pinned_while_the_content_scrolls
    expect(page).to fit_the_phone_width
  end

  it 'lines the notification cards and the mark-all action up with the 20px prototype gutter on a phone' do
    create(:notification, user: current_user, kind: 'log_reminder', data: { 'date' => '2026-11-10' })

    visit notifications_path

    card = find('#screen-content .rounded-xl', match: :first)
    mark_all = find('#screen-header').find_button(I18n.t('notifications.index.read_all'))

    expect(box(card)['x'].round).to eq(20)
    expect(box(mark_all)['right'].round).to eq(370)
    expect(page).to fit_the_phone_width
  end

  it 'highlights the maintenance from a maintenance_due notification on a phone' do
    @oil.update!(last_done_km: 155_600)

    visit notifications_path
    click_on I18n.t('notifications.kinds.maintenance_due.title_overdue', item: 'Troca de óleo')

    expect(page).to have_current_path(vehicle_path)
    expect(page).to have_css("#maintenance_#{@oil.id}.ring-amber-400")
    expect(page).to have_no_css("#maintenance_#{@oil.id}.ring-amber-400", wait: 3)
  end

  it 'marks a maintenance done inline without leaving the center on a phone' do
    @oil.update!(last_done_km: 155_600)

    visit notifications_path
    click_on I18n.t('notifications.actions.mark_done')

    expect(page).to have_text(I18n.t('maintenances.mark_done.title', item: 'Troca de óleo'))

    click_on I18n.t('maintenances.mark_done.buttons.save')

    expect(page).to have_text(I18n.t('maintenances.mark_done.toast', item: 'Troca de óleo', km: '160.928', count: 1))
    expect(@oil.reload.last_done_km).to eq(160_928)
    expect(page).to fit_the_phone_width
  end

  it 'removes a notification from the ⋯ menu on a phone' do
    notification = create(:notification, user: current_user, kind: 'log_reminder', data: { 'date' => '2026-11-11' })

    visit notifications_path
    click_on I18n.t('notifications.menu.label')
    click_on I18n.t('notifications.menu.remove')

    expect(page).to have_no_text(I18n.t('notifications.kinds.log_reminder.title'))
    expect(notification.reload.dismissed_at).to be_present
  end

  it 'refreshes the bell badge after going back on a phone' do
    create(:notification, user: current_user, kind: 'goal_reached',
                          data: { 'goal_id' => 1, 'month' => '2026-07-01', 'current' => 1_200.0 })
    create(:notification, user: current_user, kind: 'weekly_summary',
                          data: { 'week_start' => '2026-11-02', 'profit' => 500.0, 'trips' => 10 })

    visit root_path
    expect(find(:link, I18n.t('notifications.index.title'))).to have_text('2')

    click_on I18n.t('notifications.index.title')
    click_on I18n.t('notifications.kinds.goal_reached.title')
    expect(page).to have_current_path(goals_path)
    page.go_back
    page.go_back

    expect(page).to have_current_path(root_path)
    expect(find(:link, I18n.t('notifications.index.title'))).to have_text('1')
  end

  it 'mutes a kind from the ⋯ menu and undoes it on a phone' do
    create(:notification, user: current_user, kind: 'log_reminder', data: { 'date' => '2026-11-11' })

    visit notifications_path
    click_on I18n.t('notifications.menu.label')
    click_on I18n.t('notifications.menu.mute')

    expect(page).to have_text(I18n.t('notifications.muted.toast', kind: I18n.t('notifications.preferences.kinds.log_reminder.title')))
    expect(page).to have_no_text(I18n.t('notifications.kinds.log_reminder.title'))

    click_on I18n.t('notifications.muted.undo')

    expect(page).to have_text(I18n.t('notifications.kinds.log_reminder.title'))
    expect(page).to fit_the_phone_width
  end

  it 'opens the preferences from the ⚙ on a desktop screen' do
    emulate_desktop_screen

    visit notifications_path
    click_on I18n.t('notifications.index.preferences')

    expect(page).to have_current_path(edit_notification_preferences_path)
  end

  it 'opens the refueling form over the center on a desktop screen' do
    emulate_desktop_screen
    create(:refueling, vehicle: @vehicle, full_tank: true, vendor: 'Posto Orense', date: Date.current - 1)
    create(:notification, user: current_user, kind: 'tank_low', data: { 'status' => 'negative' })

    visit notifications_path
    click_on I18n.t('notifications.actions.refuel')

    expect(page).to have_text(I18n.t('refuelings.form.title_new'))
    expect(page).to have_field('refueling[vendor]', with: 'Posto Orense')
    expect(page).to have_field('refueling[odometer_km]', with: '160928', type: 'hidden')
    expect(page).to have_text(I18n.t('notifications.index.title'))
  end

  it 'marks all as read and then clears the center on a phone' do
    create(:notification, user: current_user, kind: 'log_reminder', data: { 'date' => '2026-11-11' })

    visit notifications_path
    click_on I18n.t('notifications.index.read_all')

    expect(page).to have_button(I18n.t('notifications.index.clear_all'))
    expect(page).to fit_the_phone_width

    click_on I18n.t('notifications.index.clear_all')

    expect(page).to have_text(I18n.t('notifications.index.empty.title'))
    expect(page).to have_no_button(I18n.t('notifications.index.clear_all'))
    expect(page).to fit_the_phone_width
  end

  it 'clears the read notifications from the header on a desktop screen' do
    emulate_desktop_screen
    create(:notification, user: current_user, kind: 'log_reminder', data: { 'date' => '2026-11-11' },
                          read_at: Time.current)

    visit notifications_path
    click_on I18n.t('notifications.index.clear_all')

    expect(page).to have_text(I18n.t('notifications.index.empty.title'))
  end
end
