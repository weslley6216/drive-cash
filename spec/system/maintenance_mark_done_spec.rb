require 'rails_helper'

RSpec.describe 'Maintenance mark done', type: :system, js: true do
  include ActionView::RecordIdentifier

  let(:current_user) { create(:user) }

  before do
    travel_to Time.zone.local(2026, 11, 10, 10, 0)

    vehicle = create(:vehicle, user: current_user, odometer_km: 160_928)
    @oil = create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 155_600, interval_km: 5_000)
    @filter = create(:maintenance, vehicle: vehicle, category: 'oil_filter', last_done_km: 150_800, interval_km: 10_000)

    login_as(current_user)
  end

  def open_mark_done(maintenance)
    visit vehicle_path
    within("##{dom_id(maintenance)}") { click_on I18n.t('vehicle.maintenances.mark_done') }
    expect(page).to have_text(I18n.t('maintenances.mark_done.title', item: 'Troca de óleo'))
  end

  it 'blocks saving below the last km and announces the odometer advance on a phone' do
    open_mark_done(@oil)

    fill_in 'Km do serviço', with: '154900'

    expect(page).to have_text(I18n.t('maintenances.mark_done.errors.below_last', km: '155.600'))
    expect(page).to have_button(I18n.t('maintenances.mark_done.buttons.save'), disabled: true)

    fill_in 'Km do serviço', with: '161150'

    expect(page).to have_text(I18n.t('maintenances.mark_done.odometer_advance', km: '161.150'))
    expect(page).to have_button(I18n.t('maintenances.mark_done.buttons.save'), disabled: false)
    expect(page).to have_no_text(I18n.t('maintenances.mark_done.errors.below_last', km: '155.600'))
  end
end
