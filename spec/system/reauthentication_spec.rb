require 'rails_helper'

RSpec.describe 'Confirm password screen', type: :system, js: true do
  let(:current_user) { create(:user) }

  before { login_as(current_user) }

  it 'shows the security header and the card without the bottom nav on a phone' do
    visit new_reauthentication_path

    eye = find("button[aria-label='#{I18n.t('auth.password_field_component.show')}']")

    expect(page).to have_css('h1', text: I18n.t('reauthentications.new_view.header'))
    expect(page).to have_text(I18n.t('reauthentications.new_view.heading'))
    expect(page).to have_link(I18n.t('reauthentications.new_view.forgot_password'), href: new_password_path)
    expect(box(eye)['height'].round).to eq(44)
    expect(page).to fit_the_phone_width
  end

  it 'centers a 384px card under the topbar beside the sidebar on a desktop screen' do
    emulate_desktop_screen

    visit new_reauthentication_path

    card = find('h2', text: I18n.t('reauthentications.new_view.heading')).find(:xpath, '..')
    title = find('h1', text: I18n.t('reauthentications.new_view.header'))

    expect(page).to have_text(I18n.t('reauthentications.new_view.topbar_subtitle'))
    expect(box(title)['top'].round).to eq(16)
    expect(box(card)['top'].round).to eq(151)
    expect(box(card)['width'].round).to eq(384)
  end
end
