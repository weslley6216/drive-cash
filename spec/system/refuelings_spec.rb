require 'rails_helper'

RSpec.describe 'Refuelings', type: :system, js: true do
  let(:current_user) { create(:user) }

  before do
    travel_to Time.zone.local(2026, 6, 10, 10, 0)
    login_as(current_user)
  end

  context 'with six weekly refuelings' do
    before do
      vehicle = create(:vehicle, user: current_user, odometer_km: 52_000)
      (1..6).each do |week|
        create(:refueling, vehicle: vehicle, date: Date.new(2026, 6, 10) - (week * 7), odometer_km: 52_000 - (week * 500))
      end
    end

    it 'keeps the refuelings header still while the moves scroll on a phone' do
      emulate_short_phone

      visit refuelings_path

      expect(find('h1', text: I18n.t('vehicle.moves.page_title'))).to stay_pinned_while_the_content_scrolls
      expect(page).to fit_the_phone_width
    end
  end

  context 'with three tank cycles' do
    before do
      vehicle = create(:vehicle, user: current_user, odometer_km: 11_000)
      create(:refueling, vehicle: vehicle, date: Date.new(2026, 5, 19), total_amount: 254, liters: 43.4, odometer_km: 10_000, vendor: 'Posto Orense')
      create(:refueling, vehicle: vehicle, date: Date.new(2026, 5, 28), total_amount: 250, liters: 42, odometer_km: 10_483, vendor: 'Posto Geladão')
      create(:refueling, vehicle: vehicle, date: Date.new(2026, 6, 7), total_amount: 260, liters: 44.1, odometer_km: 10_950, vendor: 'Posto Orense')
      create(:expense, user: current_user, category: 'fuel', amount: 45, date: Date.new(2026, 5, 20), description: 'Rota Shopee')
      create(:expense, user: current_user, category: 'fuel', amount: 60, date: Date.new(2026, 5, 27), description: 'Rota Shopee')
      create(:expense, user: current_user, category: 'fuel', amount: 400, date: Date.new(2026, 6, 4), description: 'Rota Mercado Livre')
      create(:expense, user: current_user, category: 'fuel', amount: 45, date: Date.new(2026, 6, 9), description: 'Rota Shopee')
    end

    it 'heads the tank moves with the back to the vehicle, a wrapped title and Abastecer on a phone' do
      visit refuelings_path

      title = find('h1', text: I18n.t('vehicle.moves.page_title'))

      expect(box(title)['height']).to be >= 60
      expect(page).to have_text('Abastecimentos e consumo por rota')
      expect(page).to have_link('Abastecer', href: new_refueling_path)
      expect(page).to fit_the_phone_width

      click_on I18n.t('vehicle.moves.back')

      expect(page).to have_current_path(vehicle_path)
    end

    it 'groups the moves by tank with the running result of each cycle on a phone' do
      visit refuelings_path

      expect(page).to have_css('p.text-2xl', text: 'R$ 214,00')
      within('#tank_cycle_2026-06-07') do
        expect(page).to have_text(/Atual/i)
        expect(page).to have_text('resta R$ 214,00')
        expect(page).to have_text('Rota Shopee')
        expect(page).to have_text('Tanque cheio')
      end
      within('#tank_cycle_2026-05-28') do
        expect(page).to have_text('10,6 km/L')
        expect(page).to have_text('−R$ 1,00 além')
      end
      within('#tank_cycle_2026-05-19') do
        expect(page).to have_text('11,5 km/L')
        expect(page).to have_text('fechou em R$ 149,00')
      end
      expect(page).to have_text(I18n.t('vehicle.moves.footnote'))
      expect(page).to fit_the_phone_width
    end

    it 'filters the tank moves by refuelings and by consumption on a phone' do
      visit refuelings_path

      click_on 'Abastecimentos'

      within('#tank_cycle_2026-06-07') do
        expect(page).to have_text('Tanque cheio')
        expect(page).to have_no_text('Rota Shopee')
      end

      click_on 'Consumo'

      within('#tank_cycle_2026-06-07') do
        expect(page).to have_text('Rota Shopee')
        expect(page).to have_no_text('Tanque cheio')
      end
      expect(page).to have_css('button[role="tab"][aria-selected="true"]', text: 'Consumo')
      expect(page).to fit_the_phone_width
    end

    it 'tops the tank moves with the back to the vehicle and lists the balance after each move on a desktop screen' do
      emulate_desktop_screen

      visit refuelings_path

      topbar = find('header', text: I18n.t('vehicle.moves.page_title'))
      back = topbar.find(:link, 'Meu veículo')
      row = find('[data-tank-filter-kind="route"]', text: 'Rota Mercado Livre')

      expect(box(back)['bottom']).to be <= box(topbar.find('h1'))['top']
      expect(topbar).to have_link('Abastecer', href: new_refueling_path)
      expect(topbar).to have_text('Abastecimentos e consumo por rota · Honda Civic · 2018')
      expect(page).to have_text(/Saldo após/i)
      expect(row).to have_text('−R$ 400,00')
      expect(row).to have_css('span.text-red-700', text: '−R$ 1,00')
      expect(page).to have_css('p.text-4xl', text: 'R$ 214,00')
      expect(page).to have_no_link(I18n.t('vehicle.moves.back'))

      back.click

      expect(page).to have_current_path(vehicle_path)
    end
  end

  context 'without moves' do
    before { create(:vehicle, user: current_user) }

    it 'opens the refueling form from the empty state on a phone' do
      visit refuelings_path

      expect(page).to have_text('Nenhuma movimentação ainda')

      within('#screen-content') { click_on 'Abastecer' }

      expect(page).to have_text(I18n.t('refuelings.form.title_new'))
      expect(page).to fit_the_phone_width
    end
  end
end
