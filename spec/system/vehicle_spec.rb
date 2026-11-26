require 'rails_helper'

RSpec.describe 'Vehicle', type: :system, js: true do
  include ActionView::RecordIdentifier

  let(:current_user) { create(:user) }

  before do
    travel_to Time.zone.local(2026, 11, 10, 10, 0)
    login_as(current_user)
  end

  context 'with a vehicle' do
    before do
      @vehicle = create(:vehicle, user: current_user, odometer_km: 160_928)
      @oil = create(:maintenance, vehicle: @vehicle, category: 'oil_change', last_done_km: 155_600, interval_km: 5_000)
      @others = %w[air_filter fuel_filter tire_rotation brake_pads].map do |category|
        create(:maintenance, vehicle: @vehicle, category: category, last_done_km: 158_000, interval_km: 10_000)
      end
    end

    it 'keeps the vehicle header still while the cards scroll on a phone' do
      emulate_short_phone

      visit vehicle_path

      expect(find('h1', text: I18n.t('vehicle.title'))).to stay_pinned_while_the_content_scrolls
      expect(page).to fit_the_phone_width
    end

    it 'goes back to Mais from the arrow left of the title keeping the pencil on the right on a phone' do
      visit vehicle_path

      back = find(:link, I18n.t('vehicle.back'))
      title = find('h1', text: I18n.t('vehicle.title'))
      pencil = find("#screen-header a[href='#{edit_vehicle_path}']")

      expect(box(back)['right']).to be <= box(title)['left']
      expect(box(pencil)['left']).to be > box(title)['right']
      expect(page).to fit_the_phone_width

      back.click

      expect(page).to have_current_path(account_path)
    end

    it 'keeps the phone back out of the desktop screen' do
      emulate_desktop_screen

      visit vehicle_path

      expect(page).to have_text('Honda Civic · 2018')
      expect(page).to have_no_link(I18n.t('vehicle.back'))
    end

    it 'ends the desktop topbar with the bell after Editar, Atualizar km and a divider' do
      create(:notification, user: current_user)
      emulate_desktop_screen

      visit vehicle_path

      topbar = find('header', text: I18n.t('vehicle.title'))
      bell = topbar.find(:link, 'Notificações, 1 não lida')

      expect(topbar).to have_link(I18n.t('vehicle.edit'), href: edit_vehicle_path)
      expect(topbar).to have_link(I18n.t('vehicle.odometer.update'), href: edit_vehicle_path)
      expect(topbar).to have_no_link(I18n.t('vehicle.maintenances.add_from_catalog'))
      expect(bell).to have_css('span.bg-red-500', text: '1')
      expect(bell.evaluate_script('this.previousElementSibling.className')).to eq('w-px h-6 bg-slate-200')
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

    it 'shows the odometer hero above the tank card on a full phone screen' do
      visit vehicle_path

      odometer = find('p', text: /#{I18n.t('vehicle.odometer.label')}/i)
      tank = find_by_id('vehicle_tank_section')

      expect(box(odometer)['top']).to be < box(tank)['top']
      expect(page).to have_text('160.928')
      expect(page).to fit_the_phone_width
    end

    it 'shows the estimated cost in the maintenance meta on a phone' do
      visit vehicle_path

      expect(find_by_id(dom_id(@oil))).to have_text('· est. R$ 280,00')
      expect(page).to fit_the_phone_width
    end

    it 'keeps the estimated cost glued to its currency symbol in the maintenance meta on a desktop screen' do
      emulate_desktop_screen

      visit vehicle_path

      expect(find_by_id(dom_id(@oil)).evaluate_script('this.textContent')).to include("· custo est. R$\u00A0280,00")
    end

    it 'heads the maintenances and the tank moves with a subtitle and inline links on a desktop screen' do
      emulate_desktop_screen

      visit vehicle_path

      maintenances = find('h2', text: I18n.t('vehicle.maintenances.title'))
      catalog = find(:link, I18n.t('vehicle.maintenances.add_from_catalog'))

      expect(maintenances[:class]).to include('text-base', 'text-slate-800')
      expect(page).to have_text(I18n.t('vehicle.maintenances.by_km_desktop'))
      expect(catalog[:class]).to include('text-sm', 'text-blue-600')
      expect(box(catalog)['bottom']).to be <= box(find_by_id(dom_id(@oil)))['top']
      expect(page).to have_css('h2.text-base', text: I18n.t('vehicle.moves.title'))
      expect(page).to have_text(I18n.t('vehicle.moves.subtitle_desktop'))
      expect(find(:link, I18n.t('vehicle.moves.view_all'))[:class]).to include('text-sm')
      expect(page).to have_text(I18n.t('vehicle.moves.auto_debit_desktop'))
    end

    it 'lists the maintenances as 44px rows in a single divided card with Marcar feita on an ok item on a desktop screen' do
      emulate_desktop_screen
      ok_item = @others.first

      visit vehicle_path

      row = find_by_id(dom_id(ok_item))
      icon = row.find('div.w-11.h-11')
      name = row.find('p', text: 'Filtro de ar')
      mark_done = row.find(:link, I18n.t('vehicle.maintenances.mark_done_desktop'), href: new_maintenance_mark_done_path(ok_item))

      expect(box(icon)['width']).to eq(44)
      expect(box(mark_done)['left']).to be > box(name)['right']
      expect(row).to have_css("a[href='#{edit_maintenance_path(ok_item)}']", count: 1)
      expect(row.find(:xpath, '..')[:class]).to include('rounded-xl', 'border-slate-200', 'divide-y')
    end

    it 'opens the maintenance edit modal from the row block on a desktop screen' do
      emulate_desktop_screen

      visit vehicle_path
      find_by_id(dom_id(@oil)).find("a[href='#{edit_maintenance_path(@oil)}']").click

      expect(page).to have_text(I18n.t('maintenances.form.title_edit'))
    end

    it 'renders the tank card with its desktop layout' do
      create(:refueling, vehicle: @vehicle, date: Date.current, vendor: 'Posto Orense', liters: 44.1, total_amount: 260, full_tank: true)
      emulate_desktop_screen

      visit vehicle_path

      expect(page).to have_text(I18n.t('vehicle.tank.subtitle'))
      expect(page).to have_text(I18n.t('vehicle.tank.refuel_desktop'))
    end

    it 'sums the routes since the last full tank and lists them as fuel expenses in a divided card on a desktop screen' do
      create(:refueling, vehicle: @vehicle, date: Date.new(2026, 11, 7), vendor: 'Posto Orense', liters: 44.1, total_amount: 260, full_tank: true)
      3.times { |offset| create(:expense, user: current_user, category: 'fuel', amount: 45, description: 'Rota Shopee', date: Date.new(2026, 11, 8 + offset)) }
      emulate_desktop_screen

      visit vehicle_path

      route = find('p', text: "#{I18n.t('vehicle.moves.today')} · #{I18n.t('vehicle.moves.fuel_expense_desktop')}")

      expect(page).to have_text('Último cheio · 07 nov · Posto Orense')
      expect(page).to have_text('Consumido R$ 135,00 em 3 rotas')
      expect(route.find(:xpath, '../..')[:class].split).to include('py-3.5')
      expect(route.find(:xpath, '../../..')[:class].split).to include('rounded-xl', 'border-slate-200', 'divide-y')
    end

    it 'keeps the Combustível sub and the bordered rows in the tank moves on a phone' do
      create(:refueling, vehicle: @vehicle, date: Date.new(2026, 11, 7), vendor: 'Posto Orense', liters: 44.1, total_amount: 260, full_tank: true)
      create(:expense, user: current_user, category: 'fuel', amount: 45, description: 'Rota Shopee', date: Date.current)

      visit vehicle_path

      route = find('p', text: "#{I18n.t('vehicle.moves.today')} · #{I18n.t('vehicle.moves.fuel_expense')}")

      expect(route.find(:xpath, '../..')[:class].split).to include('py-3', 'border-b')
      expect(page).to have_no_text('Consumido')
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

  context 'without a vehicle' do
    it 'shows the empty state with a call to action when the user has no vehicle yet' do
      visit vehicle_path

      expect(page).to have_text(I18n.t('vehicle.empty.title'))
      expect(page).to have_link(I18n.t('vehicle.empty.cta'), href: '#vehicle-registration')
      expect(page).to fit_the_phone_width
    end
  end
end
