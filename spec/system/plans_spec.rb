require 'rails_helper'

RSpec.describe 'Plans', type: :system, js: true do
  it 'keeps the plan header still past the prototype back arrow while the plans scroll on a phone' do
    login_as(create(:user))
    emulate_short_phone

    visit plan_path

    title = find('h1', text: I18n.t('plans.show_view.heading'))

    expect(box(title)['x'].round).to eq(54)
    expect(title).to stay_pinned_while_the_content_scrolls
    expect(page).to fit_the_phone_width
  end

  it 'switches the prices from the toggle on the desktop topbar, which ends with the bell after a divider' do
    user = create(:user)
    create(:notification, user: user)
    login_as(user)
    emulate_desktop_screen
    visit plan_path
    topbar = find('header', text: I18n.t('plans.show_view.heading'))
    bell = topbar.find(:link, 'Notificações, 1 não lida')

    topbar.click_button(I18n.t('plans.toggle.monthly'))

    expect(page).to have_text(I18n.t('plans.pro_card.charged_monthly'))
    expect(topbar).to have_text(I18n.t('plans.show_view.desktop_subtitle'))
    expect(bell).to have_css('span.bg-red-500', text: '1')
    expect(bell.evaluate_script('this.previousElementSibling.className')).to eq('w-px h-6 bg-slate-200')
  end

  it 'keeps the desktop topbar toggle at the prototype 36px height with the discount badge on a 20px line' do
    login_as(create(:user))
    emulate_desktop_screen

    visit plan_path

    topbar = find('header', text: I18n.t('plans.show_view.heading'))

    expect(box(topbar.find(:button, I18n.t('plans.toggle.monthly')))['height']).to eq(36)
    expect(topbar.find('span', text: '−20%').evaluate_script('getComputedStyle(this).lineHeight')).to eq('20px')
  end

  it 'keeps the subscription header still past the prototype back arrow while the benefits scroll on a phone' do
    login_as(create(:user, :pro))
    emulate_short_phone

    visit plan_path

    title = find('h1', text: I18n.t('plans.subscription_view.heading'))

    expect(box(title)['x'].round).to eq(54)
    expect(title).to stay_pinned_while_the_content_scrolls
    expect(page).to fit_the_phone_width
  end

  it 'heads the desktop subscription with the plan topbar ending in the bell without the toggle' do
    user = create(:user, :pro)
    create(:notification, user: user)
    login_as(user)
    emulate_desktop_screen

    visit plan_path

    topbar = find('header', text: I18n.t('plans.subscription_view.heading'))

    expect(topbar).to have_text('Conta · Assinatura')
    expect(topbar).to have_no_button(I18n.t('plans.toggle.monthly'))
    expect(topbar.find(:link, 'Notificações, 1 não lida')).to have_css('span.bg-red-500', text: '1')
    expect(topbar).to have_no_css('span.w-px')
  end
end
