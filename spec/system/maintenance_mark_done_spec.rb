require 'rails_helper'

RSpec.describe 'Maintenance mark done', type: :system, js: true do
  include ActionView::RecordIdentifier

  let(:current_user) { create(:user) }

  before do
    travel_to Time.zone.local(2026, 11, 10, 10, 0)

    @vehicle = create(:vehicle, user: current_user, odometer_km: 160_928)
    @oil = create(:maintenance, vehicle: @vehicle, category: 'oil_change', last_done_km: 155_600, interval_km: 5_000)
    @filter = create(:maintenance, vehicle: @vehicle, category: 'oil_filter', last_done_km: 150_800, interval_km: 10_000)

    login_as(current_user)
  end

  def open_mark_done(maintenance)
    visit vehicle_path
    within("##{dom_id(maintenance)}") { click_on I18n.t('vehicle.maintenances.mark_done') }
    expect(page).to have_text(I18n.t('maintenances.mark_done.title', item: 'Troca de óleo'))
  end

  def panel_box
    find('h2', text: I18n.t('maintenances.mark_done.title', item: 'Troca de óleo'))
      .evaluate_script("this.closest('.shadow-2xl').getBoundingClientRect().toJSON()")
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

  it 'marks an overdue item done on a phone with the service km and undoes it from the toast' do
    open_mark_done(@oil)

    box = panel_box
    expect(box['bottom']).to be_within(1).of(844)
    expect(box['width']).to be_within(1).of(390)
    expect(page).to fit_the_phone_width

    fill_in 'Km do serviço', with: '160000'
    click_on 'Salvar'

    expect(page).to have_text(I18n.t('maintenances.mark_done.toast', item: 'Troca de óleo', km: '160.000', count: 2))
    expect(@oil.reload.last_done_km).to eq(160_000)
    expect(@filter.reload.last_done_km).to eq(160_000)
    expect(@vehicle.reload.odometer_km).to eq(160_928)
    expect(page).to fit_the_phone_width

    click_on 'Desfazer'

    expect(page).to have_text(I18n.t('maintenances.mark_done.undone'))
    expect(@oil.reload.last_done_km).to eq(155_600)
    expect(@filter.reload.last_done_km).to eq(150_800)
  end

  it 'opens the edit form from the pencil on a phone' do
    visit vehicle_path
    within("##{dom_id(@oil)}") { click_on I18n.t('vehicle.maintenances.edit') }

    expect(page).to have_text(I18n.t('maintenances.form.remove'))
    expect(page).to have_no_select('maintenance[category]')
    expect(page).to fit_the_phone_width
  end

  it 'opens the mark done form as a centered modal on a desktop screen' do
    emulate_desktop_screen
    open_mark_done(@oil)

    box = panel_box
    expect(box['width']).to be_within(1).of(460)
    expect(box['x']).to be_within(1).of((1280 - 460) / 2.0)
    expect(box['y']).to be > 0
    expect(box['bottom']).to be < 800

    click_on 'Salvar'

    expect(page).to have_text(I18n.t('maintenances.mark_done.toast', item: 'Troca de óleo', km: '160.928', count: 2))
  end
end
