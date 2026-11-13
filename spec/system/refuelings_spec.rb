require 'rails_helper'

RSpec.describe 'Refuelings', type: :system, js: true do
  let(:current_user) { create(:user) }

  before do
    travel_to Time.zone.local(2026, 11, 10, 10, 0)

    vehicle = create(:vehicle, user: current_user, odometer_km: 52_000)
    (1..6).each do |week|
      create(:refueling, vehicle: vehicle, date: Date.new(2026, 11, 10) - (week * 7), odometer_km: 52_000 - (week * 500))
    end

    login_as(current_user)
  end

  it 'keeps the refuelings header still while the moves scroll on a phone' do
    emulate_short_phone

    visit refuelings_path

    expect(find('h1', text: I18n.t('vehicle.moves.page_title'))).to stay_pinned_while_the_content_scrolls
    expect(page).to fit_the_phone_width
  end
end
