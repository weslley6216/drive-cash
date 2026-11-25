require 'rails_helper'

RSpec.describe 'Exports', type: :system, js: true do
  let(:current_user) { create(:user) }

  before { login_as(current_user) }

  it 'keeps the export header still past the prototype back arrow while the options scroll on a phone' do
    emulate_short_phone

    visit exports_path

    title = find('h1', text: I18n.t('exports.title'))

    expect(box(title)['x'].round).to eq(54)
    expect(title).to stay_pinned_while_the_content_scrolls
    expect(page).to fit_the_phone_width
  end

  it 'heads the desktop screen with the export topbar ending in the bell without actions' do
    create(:notification, user: current_user)
    emulate_desktop_screen

    visit exports_path

    topbar = find('header', text: I18n.t('exports.desktop_title'))

    expect(topbar).to have_text(I18n.t('exports.desktop_subtitle'))
    expect(topbar.find(:link, 'Notificações, 1 não lida')).to have_css('span.bg-red-500', text: '1')
    expect(topbar).to have_no_css('span.w-px')
  end
end
