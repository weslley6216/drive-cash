require 'rails_helper'

RSpec.describe 'Vehicle', type: :system, js: true do
  include ActionView::RecordIdentifier

  let(:current_user) { create(:user) }

  before do
    travel_to Time.zone.local(2026, 11, 10, 10, 0)

    @vehicle = create(:vehicle, user: current_user, odometer_km: 160_928)
    @oil = create(:maintenance, vehicle: @vehicle, category: 'oil_change', last_done_km: 155_600, interval_km: 5_000)
    @others = %w[air_filter fuel_filter tire_rotation brake_pads].map do |category|
      create(:maintenance, vehicle: @vehicle, category: category, last_done_km: 158_000, interval_km: 10_000)
    end

    login_as(current_user)
  end

  it 'keeps the vehicle header still while the cards scroll on a phone' do
    emulate_short_phone

    visit vehicle_path

    expect(find('h1', text: I18n.t('vehicle.title'))).to stay_pinned_while_the_content_scrolls
    expect(page).to fit_the_phone_width
  end

  it 'scrolls the highlighted maintenance into view inside the screen content on a phone' do
    emulate_short_phone
    target = @others.last

    visit vehicle_path(highlight: dom_id(target))

    row = find("##{dom_id(target)}")

    expect(screen_content_scroll_top).to be_positive
    expect(box(row)['top']).to be_between(0, ScreenGeometry::SHORT_PHONE_HEIGHT)
    expect(page).to fit_the_phone_width
  end

  it 'rings the tank card for two seconds when arriving highlighted on a phone' do
    visit vehicle_path(highlight: 'vehicle_tank')

    expect(page).to have_css('#vehicle_tank.ring-amber-400')
    expect(page).to have_no_css('#vehicle_tank.ring-amber-400', wait: 3)
    expect(page).to fit_the_phone_width
  end

  it 'keeps the content scroll after marking a maintenance done on a phone' do
    emulate_short_phone
    visit vehicle_path
    within("##{dom_id(@oil)}") { click_on I18n.t('vehicle.maintenances.mark_done') }
    expect(page).to have_text(I18n.t('maintenances.mark_done.title', item: 'Troca de óleo'))
    scrolled = screen_content_scroll_top

    fill_in 'Km do serviço', with: '160000'
    click_on 'Salvar'

    expect(page).to have_no_text(I18n.t('maintenances.mark_done.title', item: 'Troca de óleo'))
    expect(scrolled).to be_positive
    expect(screen_content_scroll_top).to eq(scrolled)
  end
end
