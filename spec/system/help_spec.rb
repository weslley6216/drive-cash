require 'rails_helper'

RSpec.describe 'Help', type: :system, js: true do
  let(:current_user) { create(:user) }

  before { login_as(current_user) }

  it 'keeps the help header still past the prototype back arrow while the FAQ scrolls on a phone' do
    emulate_short_phone

    visit help_path

    title = find('h1', text: I18n.t('help.show_view.heading'))

    expect(box(title)['x'].round).to eq(54)
    expect(title).to stay_pinned_while_the_content_scrolls
    expect(page).to fit_the_phone_width
  end

  it 'heads the desktop screen with the help center topbar ending in the bell without actions' do
    create(:notification, user: current_user)
    emulate_desktop_screen

    visit help_path

    topbar = find('header', text: I18n.t('help.show_view.heading'))

    expect(topbar).to have_text('Conta · Central de ajuda')
    expect(topbar).to have_no_text(I18n.t('help.show_view.subtitle'))
    expect(topbar.find(:link, 'Notificações, 1 não lida')).to have_css('span.bg-red-500', text: '1')
    expect(topbar).to have_no_css('span.w-px')
  end
end
