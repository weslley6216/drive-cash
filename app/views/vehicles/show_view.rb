module Vehicles
  class ShowView < ApplicationView
    def initialize(payload:, vehicle_form: nil)
      @payload = payload
      @vehicle_form = vehicle_form
    end

    def view_template
      render LayoutComponent.new(title: t('vehicle.title'), bottom_nav: :more, sidebar_nav: :vehicle) do
        div(id: 'flash') { render FlashComponent.new(flash: helpers.flash) }

        if @vehicle_form
          empty_state
        else
          dashboard_layout
        end

        turbo_frame_tag 'modal'
      end
    end

    private

    def empty_state
      div(class: 'py-12') do
        render Vehicles::RegistrationFormComponent.new(vehicle: @vehicle_form)
      end
    end

    def dashboard_layout
      div(class: 'lg:hidden') { mobile_layout }
      div(class: 'hidden lg:block') { desktop_layout }
    end

    def mobile_layout
      div(class: 'space-y-4') do
        header_mobile
        render Vehicles::OdometerHeroComponent.new(
          current_km: @payload[:odometer][:current_km],
          km_this_month: @payload[:odometer][:km_this_month]
        )
        render Vehicles::MetricsRowComponent.new(metrics: @payload[:metrics])
        mobile_maintenances_section
        mobile_refuelings_section
        insight_section
      end
    end

    def header_mobile
      div(class: 'flex items-center justify-between mb-2') do
        div do
          h1(class: 'text-xl font-bold text-slate-900') { t('vehicle.title') }
          p(class: 'text-xs text-slate-500') { vehicle_subtitle }
        end
      end
    end

    def vehicle_subtitle
      vehicle = @payload[:vehicle]
      return '' unless vehicle

      t('vehicle.subtitle', brand: vehicle.brand, vehicle_model: vehicle.vehicle_model, year: vehicle.year)
    end

    def mobile_maintenances_section
      div do
        section_header(title_key: 'vehicle.maintenances.title',
                       link_text: t('vehicle.maintenances.add'),
                       link_path: helpers.new_maintenance_path)
        div(class: 'space-y-2') do
          maintenances = @payload[:upcoming_maintenances]
          if maintenances.empty?
            empty_row(t('vehicle.maintenances.empty'))
          else
            maintenances.each { |entry| render Vehicles::MaintenanceCardComponent.new(**entry) }
          end
        end
      end
    end

    def mobile_refuelings_section
      div do
        section_header(title_key: 'vehicle.refuelings.title',
                       link_text: t('vehicle.refuelings.view_all'),
                       link_path: helpers.new_refueling_path)
        refuelings = @payload[:recent_refuelings]
        if refuelings.empty?
          empty_row(t('vehicle.refuelings.empty'))
        else
          div(class: 'bg-white rounded-xl border border-slate-100 divide-y divide-slate-100') do
            refuelings.each { |entry| render Vehicles::RefuelingRowComponent.new(**entry) }
          end
        end
      end
    end

    def desktop_layout
      div(class: 'space-y-6') do
        desktop_topbar
        desktop_row_one
        desktop_row_two
        insight_section
      end
    end

    def desktop_topbar
      div(class: 'flex items-start justify-between') do
        div do
          h1(class: 'text-2xl font-bold text-slate-900') { t('vehicle.title') }
          p(class: 'text-sm text-slate-500') { vehicle_subtitle }
        end
        div(class: 'flex items-center gap-2') do
          link_to(t('vehicle.maintenances.add'), helpers.new_maintenance_path,
                  class: 'inline-flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg px-4 py-2 text-sm font-semibold',
                  data: { turbo_frame: 'modal' })
        end
      end
    end

    def desktop_row_one
      div(class: 'grid grid-cols-12 gap-4') do
        div(class: 'col-span-5') do
          render Vehicles::OdometerHeroComponent.new(
            current_km: @payload[:odometer][:current_km],
            km_this_month: @payload[:odometer][:km_this_month],
            variant: :desktop
          )
        end
        div(class: 'col-span-7') do
          render Vehicles::MetricsRowComponent.new(metrics: @payload[:metrics], variant: :desktop)
        end
      end
    end

    def desktop_row_two
      div(class: 'grid grid-cols-12 gap-4') do
        div(class: 'col-span-7') do
          section_header(title_key: 'vehicle.maintenances.title',
                         link_text: t('vehicle.maintenances.add'),
                         link_path: helpers.new_maintenance_path)
          div(class: 'space-y-2') do
            maintenances = @payload[:upcoming_maintenances]
            if maintenances.empty?
              empty_row(t('vehicle.maintenances.empty'))
            else
              maintenances.each do |entry|
                render Vehicles::MaintenanceCardComponent.new(**entry.merge(variant: :desktop))
              end
            end
          end
        end
        div(class: 'col-span-5') do
          section_header(title_key: 'vehicle.refuelings.title',
                         link_text: t('vehicle.refuelings.view_all'),
                         link_path: helpers.new_refueling_path)
          render Vehicles::RefuelingsTableComponent.new(entries: @payload[:recent_refuelings])
        end
      end
    end

    def insight_section
      insight = @payload[:insights].first
      return unless insight

      render Vehicles::InsightCardComponent.new(insight: insight)
    end

    def section_header(title_key:, link_text:, link_path:)
      div(class: 'flex items-center justify-between mb-2 px-1') do
        h3(class: 'text-sm font-semibold text-slate-700') { t(title_key) }
        link_to(link_text, link_path,
                class: 'text-xs font-medium text-blue-600',
                data: { turbo_frame: 'modal' })
      end
    end

    def empty_row(message)
      div(class: 'bg-white rounded-xl border border-slate-100 p-6 text-center text-sm text-slate-500') { message }
    end
  end
end
