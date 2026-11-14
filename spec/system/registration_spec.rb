require 'rails_helper'

RSpec.describe 'Sign up screen', type: :system, js: true do
  it 'stacks the brand, the form and Google with 44px touch targets on a phone' do
    visit new_registration_path

    submit = find('button', text: I18n.t('registrations.new_view.submit'))
    eye = first("button[aria-label='#{I18n.t('auth.password_field_component.show')}']")

    expect(page).to have_text(I18n.t('brand_mark_component.subtitle'))
    expect(page).to have_text(I18n.t('registrations.new_view.password_hint'))
    expect(page).to have_text(I18n.t('auth.google_button_component.label'))
    expect(box(submit)['height']).to be >= 44
    expect(box(eye)['height'].round).to eq(44)
    expect(page).to fit_the_phone_width
  end

  it 'splits the brand panel and a 384px form on a desktop screen' do
    emulate_desktop_screen

    visit new_registration_path

    panel = find('h2', text: I18n.t('auth.brand_panel_component.headline_line1')).find(:xpath, '../..')
    form = find('form[action="/registrations"]')

    expect(box(panel)['width'].round).to eq((1280 * 0.46).round)
    expect(box(form)['width'].round).to eq(384)
  end
end
