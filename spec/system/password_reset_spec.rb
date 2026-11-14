require 'rails_helper'

RSpec.describe 'Password reset screens', type: :system, js: true do
  let(:user) { create(:user) }

  it 'sends the link, shows the sent screen and resends it on a phone' do
    Rails.cache.clear
    visit new_password_path

    back = find('a', text: I18n.t('auth.back_to_login_component.label'))

    expect(box(back)['height'].round).to eq(44)
    expect(page).to fit_the_phone_width

    fill_in I18n.t('passwords.new_view.email'), with: user.email_address
    click_on I18n.t('passwords.new_view.submit')

    expect(page).to have_text(I18n.t('passwords.sent_view.heading'))
    expect(page).to have_text(user.email_address)
    expect(box(find('button', text: I18n.t('passwords.sent_view.resend')))['height'].round).to eq(44)
    expect(page).to fit_the_phone_width

    click_on I18n.t('passwords.sent_view.resend')

    expect(page).to have_text(I18n.t('passwords.sent_view.heading'))
  end

  it 'shows the mismatch inline under the confirmation on a phone' do
    visit edit_password_path(user.password_reset_token)

    fill_in I18n.t('passwords.edit_view.password'), with: 'newpassword'
    fill_in I18n.t('passwords.edit_view.password_confirmation'), with: 'mismatch1'
    click_on I18n.t('passwords.edit_view.submit')

    expect(page).to have_text(I18n.t('activerecord.errors.models.user.attributes.password_confirmation.confirmation'))
    expect(page).to have_css('input#password_confirmation.border-red-300')
    expect(page).to have_text(I18n.t('brand_mark_component.subtitle'))
    expect(page).to fit_the_phone_width
  end

  it 'splits the brand panel and a 384px column on a desktop screen' do
    emulate_desktop_screen

    visit new_password_path

    panel = find('h2', text: I18n.t('auth.brand_panel_component.headline_line1')).find(:xpath, '../..')
    form = find('form[action="/passwords"]')

    expect(box(panel)['width'].round).to eq((1280 * 0.46).round)
    expect(box(form)['width'].round).to eq(384)
    expect(page).to have_link(I18n.t('auth.back_to_login_component.label'))
  end

  it 'keeps the sent screen and its resend button inside the 384px column on a desktop screen' do
    Rails.cache.clear
    emulate_desktop_screen
    visit new_password_path
    fill_in I18n.t('passwords.new_view.email'), with: user.email_address
    click_on I18n.t('passwords.new_view.submit')

    heading = find('h1', text: I18n.t('passwords.sent_view.heading'))
    resend = find('button', text: I18n.t('passwords.sent_view.resend'))

    expect(box(heading.find(:xpath, '..'))['width'].round).to eq(384)
    expect(box(resend)['width'].round).to eq(384)
    expect(page).to have_text(I18n.t('auth.brand_panel_component.headline_line1'))
  end

  it 'shows the new password pair in the 384px column beside the brand panel on a desktop screen' do
    token = user.password_reset_token
    emulate_desktop_screen

    visit edit_password_path(token)

    panel = find('h2', text: I18n.t('auth.brand_panel_component.headline_line1')).find(:xpath, '../..')
    form = find("form[action='#{password_path(token)}']")

    expect(box(panel)['width'].round).to eq((1280 * 0.46).round)
    expect(box(form)['width'].round).to eq(384)
    expect(form).to have_field(I18n.t('passwords.edit_view.password_confirmation'))
  end
end
