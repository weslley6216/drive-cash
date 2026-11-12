require 'rails_helper'

RSpec.describe 'Sign in screen', type: :system, js: true do
  def box(element)
    element.evaluate_script('this.getBoundingClientRect().toJSON()')
  end

  it 'stacks the brand on top, pins the sign-up link to the bottom and keeps a 44px button on a phone' do
    visit new_session_path

    footer = find('p', text: I18n.t('sessions.new_view.no_account'))
    submit = find('button', text: I18n.t('sessions.new_view.sign_in'))
    divider = find('span', text: I18n.t('sessions.new_view.divider'), exact_text: true)

    expect(page).to have_text(I18n.t('brand_mark_component.subtitle'))
    expect(I18n.t('brand_mark_component.subtitle')).to eq('Gestão financeira')
    expect(box(footer)['bottom']).to be > 780
    expect(box(divider)['top'] - box(submit)['bottom']).to be >= 16
    expect(box(submit)['height']).to be >= 44
    expect(page).to fit_the_phone_width
  end

  it 'splits brand panel and form with the desktop subtitle on a desktop screen' do
    emulate_desktop_screen

    visit new_session_path

    panel = find('h2', text: I18n.t('sessions.new_view.brand_headline_line1')).find(:xpath, '../..')

    brand_title = within(panel) { find('p', text: I18n.t('brand_mark_component.title'), exact_text: true) }

    expect(box(panel)['width'].round).to eq((1280 * 0.46).round)
    expect(brand_title.evaluate_script('getComputedStyle(this).fontSize')).to eq('20px')
    expect(page).to have_text(I18n.t('sessions.new_view.welcome_subtitle_desktop'))
    expect(page).to have_no_text(I18n.t('sessions.new_view.welcome_subtitle'))
  end
end
