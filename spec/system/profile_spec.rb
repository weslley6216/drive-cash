require 'rails_helper'

RSpec.describe 'Profile', type: :system, js: true do
  let(:current_user) { create(:user) }

  before { login_as(current_user) }

  it 'keeps the personal data header still past the prototype back arrow while the form scrolls on a phone' do
    emulate_short_phone

    visit edit_profile_path

    title = find('h1', text: I18n.t('profiles.edit_view.heading'))

    expect(box(title)['x'].round).to eq(54)
    expect(title).to stay_pinned_while_the_content_scrolls
    expect(page).to fit_the_phone_width
  end

  it 'puts a 220px save button on the desktop topbar before a divider and the bell' do
    create(:notification, user: current_user)
    emulate_desktop_screen

    visit edit_profile_path

    topbar = find('header', text: I18n.t('profiles.edit_view.heading'))
    bell = topbar.find(:link, 'Notificações, 1 não lida')

    expect(topbar).to have_text(I18n.t('profiles.edit_view.desktop_subtitle'))
    expect(box(topbar.find(:button, I18n.t('profiles.edit_view.save')))['width'].round).to eq(220)
    expect(bell).to have_css('span.bg-red-500', text: '1')
    expect(bell.evaluate_script('this.previousElementSibling.className')).to eq('w-px h-6 bg-slate-200')
  end

  it 'saves the profile from the button on the desktop topbar outside the form' do
    emulate_desktop_screen
    visit edit_profile_path
    fill_in I18n.t('profiles.edit_view.name'), with: 'Joana Motorista'

    find('header', text: I18n.t('profiles.edit_view.heading')).click_button(I18n.t('profiles.edit_view.save'))

    expect(page).to have_text(I18n.t('profiles.flash.saved'))
    expect(current_user.reload.name).to eq('Joana Motorista')
  end
end
