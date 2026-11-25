require 'rails_helper'

RSpec.describe Vehicles::MaintenanceRowComponent, type: :component do
  describe '#view_template' do
    it 'renders an on-track item with catalog label and remaining km' do
      vehicle = create(:vehicle, odometer_km: 160_000)
      create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 158_000, interval_km: 5_000)
      row = Vehicles::MaintenanceService.new(user: vehicle.user).call[:maintenances].first

      html = view_context.render(described_class.new(row: row))

      expect(html).to include(I18n.t('vehicle.maintenances.catalog.oil_change'))
      expect(html).to include(I18n.t('vehicle.maintenances.status.ok'))
      expect(html).to include('faltam')
    end

    it 'renders an overdue item with the overdue copy and red color' do
      vehicle = create(:vehicle, odometer_km: 165_000)
      create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 158_000, interval_km: 5_000)
      row = Vehicles::MaintenanceService.new(user: vehicle.user).call[:maintenances].first

      html = view_context.render(described_class.new(row: row))

      expect(html).to include(I18n.t('vehicle.maintenances.status.overdue'))
      expect(html).to include('venceu há')
      expect(html).to include('#dc2626')
    end

    it 'renders the mark done link for a soon item' do
      vehicle = create(:vehicle, odometer_km: 160_000)
      create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 155_500, interval_km: 5_000)
      row = Vehicles::MaintenanceService.new(user: vehicle.user).call[:maintenances].first

      html = view_context.render(described_class.new(row: row))

      expect(html).to include(Rails.application.routes.url_helpers.new_maintenance_mark_done_path(row.maintenance))
      expect(html).to include(I18n.t('vehicle.maintenances.mark_done'))
    end

    it 'renders the mark done link for an overdue item' do
      vehicle = create(:vehicle, odometer_km: 165_000)
      create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 158_000, interval_km: 5_000)
      row = Vehicles::MaintenanceService.new(user: vehicle.user).call[:maintenances].first

      html = view_context.render(described_class.new(row: row))

      expect(html).to include(Rails.application.routes.url_helpers.new_maintenance_mark_done_path(row.maintenance))
    end

    it 'omits the mark done link for an ok item' do
      vehicle = create(:vehicle, odometer_km: 160_000)
      create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 159_000, interval_km: 5_000)
      row = Vehicles::MaintenanceService.new(user: vehicle.user).call[:maintenances].first

      html = view_context.render(described_class.new(row: row))

      expect(html).not_to include(Rails.application.routes.url_helpers.new_maintenance_mark_done_path(row.maintenance))
    end

    it 'renders the edit link on every row' do
      vehicle = create(:vehicle, odometer_km: 160_000)
      create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 159_000, interval_km: 5_000)
      row = Vehicles::MaintenanceService.new(user: vehicle.user).call[:maintenances].first

      html = view_context.render(described_class.new(row: row))

      expect(html).to include(Rails.application.routes.url_helpers.edit_maintenance_path(row.maintenance))
      expect(html).to include('data-turbo-frame="modal"')
    end

    it 'appends the estimated cost to the meta line' do
      vehicle = create(:vehicle, odometer_km: 160_000)
      create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 158_000, interval_km: 5_000, estimated_cost: 280)
      row = Vehicles::MaintenanceService.new(user: vehicle.user).call[:maintenances].first

      html = view_context.render(described_class.new(row: row))

      expect(Capybara.string(html)).to have_css('p span.text-slate-400', text: '· est. R$ 280,00')
    end

    it 'omits the estimated cost when the maintenance has none' do
      vehicle = create(:vehicle, odometer_km: 160_000)
      create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 158_000, interval_km: 5_000, estimated_cost: nil)
      row = Vehicles::MaintenanceService.new(user: vehicle.user).call[:maintenances].first

      html = view_context.render(described_class.new(row: row))

      expect(html).to include('faltam')
      expect(html).not_to include('est.')
    end

    context 'with the desktop variant' do
      it 'renders the 44px icon inside a px-5 py-4 row' do
        vehicle = create(:vehicle, odometer_km: 160_000)
        create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 159_000, interval_km: 5_000)
        row = Vehicles::MaintenanceService.new(user: vehicle.user).call[:maintenances].first

        page = Capybara.string(view_context.render(described_class.new(row: row, variant: :desktop)))

        expect(page).to have_css("div#maintenance_#{row.maintenance.id}.flex.items-center.gap-4.px-5.py-4")
        expect(page).to have_css('div.w-11.h-11.rounded-xl svg.w-5.h-5')
      end

      it 'keeps a single edit link wrapping the icon and the name' do
        vehicle = create(:vehicle, odometer_km: 160_000)
        create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 159_000, interval_km: 5_000)
        row = Vehicles::MaintenanceService.new(user: vehicle.user).call[:maintenances].first
        edit_path = Rails.application.routes.url_helpers.edit_maintenance_path(row.maintenance)

        page = Capybara.string(view_context.render(described_class.new(row: row, variant: :desktop)))

        expect(page).to have_css("a[href='#{edit_path}']", count: 1)
        expect(page).to have_css("a[href='#{edit_path}'][data-turbo-frame='modal'][aria-label='#{I18n.t('vehicle.maintenances.edit')}']",
                                 text: I18n.t('vehicle.maintenances.catalog.oil_change'))
        expect(page).to have_css("a[href='#{edit_path}'] div.w-11.h-11")
      end

      it 'renders Marcar feita for an ok item' do
        vehicle = create(:vehicle, odometer_km: 160_000)
        create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 159_000, interval_km: 5_000)
        row = Vehicles::MaintenanceService.new(user: vehicle.user).call[:maintenances].first
        mark_done_path = Rails.application.routes.url_helpers.new_maintenance_mark_done_path(row.maintenance)

        page = Capybara.string(view_context.render(described_class.new(row: row, variant: :desktop)))

        expect(page).to have_css("a.rounded-lg.px-3.py-1\\.5.flex-shrink-0[href='#{mark_done_path}'][data-turbo-frame='modal']",
                                 text: I18n.t('vehicle.maintenances.mark_done_desktop'))
      end

      it 'renders the progress bar inside the info block' do
        vehicle = create(:vehicle, odometer_km: 160_000)
        create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 159_000, interval_km: 5_000)
        row = Vehicles::MaintenanceService.new(user: vehicle.user).call[:maintenances].first

        page = Capybara.string(view_context.render(described_class.new(row: row, variant: :desktop)))

        expect(page).to have_css('a div.flex-1.min-w-0 div.h-1\\.5.mt-2.max-w-md')
      end

      it 'shows the target km after the overdue copy' do
        vehicle = create(:vehicle, odometer_km: 165_000)
        create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 158_000, interval_km: 5_000)
        row = Vehicles::MaintenanceService.new(user: vehicle.user).call[:maintenances].first

        page = Capybara.string(view_context.render(described_class.new(row: row, variant: :desktop)))

        expect(page).to have_css('span.font-semibold.text-red-600', text: 'venceu há 2.000 km · aos 163.000 km')
      end

      it 'shows the desktop estimated cost copy' do
        vehicle = create(:vehicle, odometer_km: 160_000)
        create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 159_000, interval_km: 5_000, estimated_cost: 280)
        row = Vehicles::MaintenanceService.new(user: vehicle.user).call[:maintenances].first

        page = Capybara.string(view_context.render(described_class.new(row: row, variant: :desktop)))

        expect(page).to have_css('p span.text-slate-400', text: '· custo est. R$ 280,00')
      end
    end
  end
end
