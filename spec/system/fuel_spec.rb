require 'rails_helper'

RSpec.describe 'Fuel', type: :system, js: true do
  let(:current_user) { create(:user) }
  let(:vehicle) { create(:vehicle, user: current_user, odometer_km: 160_928) }

  before do
    travel_to Time.zone.local(2026, 6, 10, 10, 0)
    login_as(current_user)
  end

  it 'shows the suggested vendor and km with a 44px vendor chip on a phone' do
    create(:refueling, vehicle: vehicle, vendor: 'Geladão', full_tank: true, date: Date.current - 3)

    visit vehicle_path
    click_on I18n.t('vehicle.tank.refuel')

    chip = find('button', text: 'Geladão')

    expect(page).to have_field('refueling[vendor]', with: 'Geladão')
    expect(page).to have_field('refueling[odometer_km]', with: '160928', type: 'hidden')
    expect(box(chip)['height']).to be >= 44
    expect(page).to fit_the_phone_width
  end

  it 'fills the chip of the vendor in the field red and moves it to the tapped chip on a phone' do
    create(:refueling, vehicle: vehicle, vendor: 'Shell Centro', full_tank: true, date: Date.current - 9)
    create(:refueling, vehicle: vehicle, vendor: 'Geladão', full_tank: true, date: Date.current - 3)
    visit vehicle_path
    click_on I18n.t('vehicle.tank.refuel')

    expect(page).to have_css('button[aria-pressed="true"].bg-red-600', text: 'Geladão')
    expect(page).to have_css('button[aria-pressed="false"].bg-white', text: 'Shell Centro')

    find('button', text: 'Shell Centro').click

    expect(page).to have_field('refueling[vendor]', with: 'Shell Centro')
    expect(page).to have_css('button[aria-pressed="true"].bg-red-600', text: 'Shell Centro')
    expect(page).to have_css('button[aria-pressed="false"].bg-white', text: 'Geladão')
    expect(page).to fit_the_phone_width
  end

  it 'divides the refuel modal header with the light slate line of the prototype on a phone' do
    create(:refueling, vehicle: vehicle, vendor: 'Geladão', full_tank: true, date: Date.current - 3)
    visit vehicle_path
    click_on I18n.t('vehicle.tank.refuel')

    header = find('h2', text: I18n.t('refuelings.form.title_new')).find(:xpath, '..')
    slate_line = page.evaluate_script(<<~JS)
      (() => {
        const probe = document.createElement('div');
        probe.className = 'border border-slate-200';
        document.body.append(probe);
        const color = getComputedStyle(probe).borderTopColor;
        probe.remove();
        return color;
      })()
    JS

    expect(header.evaluate_script('getComputedStyle(this).borderBottomColor')).to eq(slate_line)
    expect(page).to fit_the_phone_width
  end

  it 'inherits the vendor from the active tank on a phone' do
    vehicle.update!(odometer_km: 160_928)
    create(:refueling, vehicle: vehicle, vendor: 'Posto Orense', full_tank: true, date: Date.current - 1)

    visit new_record_path(type: 'expense')
    find('label', text: I18n.t('activerecord.attributes.expense.categories.fuel')).click
    click_on 'Usar Posto Orense'

    expect(page).to have_field('record[vendor]', with: 'Posto Orense')
    expect(page).to have_text(I18n.t('records.new_view.vendor_inherited'))
    expect(page).to fit_the_phone_width
  end

  it 'shows the tank balance before and after the typed amount on a phone' do
    create(:refueling, vehicle: vehicle, vendor: 'Posto Orense', total_amount: 260, full_tank: true, date: Date.current - 1)

    visit new_record_path(type: 'expense')
    find('label', text: I18n.t('activerecord.attributes.expense.categories.fuel')).click
    find('[data-record-form-target="amountDisplay"]').set('8000')

    expect(page).to have_text(I18n.t('records.new_view.tank_debit.title'))
    expect(page).to have_text('Saldo R$ 260,00 → R$ 180,00', normalize_ws: true)
    expect(page).to fit_the_phone_width
  end

  it 'formats the after tank balance with a non-breaking space after the currency symbol on a phone' do
    create(:refueling, vehicle: vehicle, vendor: 'Posto Orense', total_amount: 260, full_tank: true, date: Date.current - 1)

    visit new_record_path(type: 'expense')
    find('label', text: I18n.t('activerecord.attributes.expense.categories.fuel')).click
    find('[data-record-form-target="amountDisplay"]').set('8000')

    expect(page).to have_css('[data-record-form-target="tankAfter"]', exact_text: 'R$ 180,00')
    expect(page.evaluate_script(%(document.querySelector('[data-record-form-target="tankAfter"]').textContent))).to eq("R$\u00A0180,00")
    expect(page).to fit_the_phone_width
  end

  it 'hides the tank debit card for a non-fuel category on a phone' do
    create(:refueling, vehicle: vehicle, vendor: 'Posto Orense', total_amount: 260, full_tank: true, date: Date.current - 1)

    visit new_record_path(type: 'expense')
    find('label', text: I18n.t('activerecord.attributes.expense.categories.maintenance')).click

    expect(page).to have_no_text(I18n.t('records.new_view.tank_debit.title'))
    expect(page).to fit_the_phone_width
  end
end
