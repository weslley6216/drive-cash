require 'rails_helper'

RSpec.describe 'App shell', type: :system, js: true do
  let(:current_user) { create(:user, name: 'Weslley Campos') }

  before { login_as(current_user) }

  it 'shows the bottom nav with the active tab in the prototype blue and a 20px gutter on a phone' do
    visit root_path

    active_tab = find('#bottom-nav a', text: I18n.t('bottom_nav_component.tabs.home'))

    expect(page).to have_css('#bottom-nav', visible: true)
    expect(active_tab.evaluate_script('getComputedStyle(this).color')).to eq('rgb(37, 99, 235)')
    expect(box(find('h1'))['x'].round).to eq(20)
    expect(page).to fit_the_phone_width
  end

  it 'keeps the phone shell inside the screen in dark mode' do
    emulate_color_scheme('dark')

    visit root_path

    expect(page).to have_css('#bottom-nav', visible: true)
    expect(page).to fit_the_phone_width
  end

  it 'starts the Home header 24px below the top like the prototype, with an opaque slate bar behind the status bar on a phone' do
    visit root_path

    eyebrow = find('p', text: I18n.t('dashboard.index_view.eyebrow').upcase)

    expect(box(eyebrow)['top'].round).to eq(24)
    expect(computed('#safe-top-bar', 'position')).to eq('fixed')
    expect(computed('#safe-top-bar', 'backgroundColor')).to eq('rgb(248, 250, 252)')
    expect(computed('#safe-top-bar', 'zIndex')).to eq('40')
    expect(computed('#bottom-nav', 'paddingBottom')).to eq('24px')
    expect(page).to fit_the_phone_width
  end

  it 'starts the vehicle title 24px below the top like the prototype on a phone' do
    create(:vehicle, user: current_user)

    visit vehicle_path

    expect(page).to have_css('h1', text: I18n.t('vehicle.title'))
    expect(box(find('h1'))['top'].round).to eq(24)
    expect(page).to fit_the_phone_width
  end

  it 'shows a 240px sidebar with the profile footer and hides the bottom nav on a desktop screen' do
    emulate_desktop_screen

    visit root_path

    footer = find('#sidebar-nav a[href="/account"]')

    expect(box(find('#sidebar-nav'))['width'].round).to eq(240)
    expect(page).to have_no_css('#bottom-nav', visible: true)
    expect(footer).to have_text('Weslley')
    expect(footer).to have_text(I18n.t('sidebar_nav_component.account_hint'))
    expect(page).to have_no_button(I18n.t('sessions.sign_out'))
  end
end
