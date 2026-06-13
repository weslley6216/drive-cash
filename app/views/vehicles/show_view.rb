module Vehicles
  class ShowView < ApplicationView
    MOBILE_MAINTENANCE_LIMIT = 5

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
      div(class: 'py-12 space-y-6') do
        render Vehicles::EmptyVehicleComponent.new
        div(id: 'vehicle-registration') do
          render Vehicles::RegistrationFormComponent.new(vehicle: @vehicle_form)
        end
      end
    end

    def dashboard_layout
      div(class: 'lg:hidden') { mobile_layout }
      div(class: 'hidden lg:block') { desktop_layout }
    end

    def odometer
      @payload[:odometer]
    end

    def tank
      @payload[:tank]
    end

    def maintenances
      @payload[:maintenances]
    end

    def vehicle_subtitle
      vehicle = @payload[:vehicle]
      return '' unless vehicle

      t('vehicle.subtitle', brand: vehicle.brand, vehicle_model: vehicle.vehicle_model, year: vehicle.year)
    end

    def mobile_layout
      div(class: 'space-y-4') do
        header_mobile
        render Vehicles::OdometerHeroComponent.new(current_km: odometer[:current_km], km_this_month: odometer[:km_this_month], updated_days_ago: odometer[:updated_days_ago])
        render_tank_card
        maintenances_section(limit: MOBILE_MAINTENANCE_LIMIT)
        moves_section
        insight_section
      end
    end

    def header_mobile
      div(class: 'flex items-center justify-between mb-2') do
        div do
          h1(class: 'text-xl font-bold text-slate-900') { t('vehicle.title') }
          p(class: 'text-xs text-slate-500') { vehicle_subtitle }
        end
        link_to(helpers.edit_vehicle_path,
                class: 'w-9 h-9 rounded-full bg-white border border-slate-200 shadow-sm flex items-center justify-center text-slate-600',
                data: { turbo_frame: 'modal' }) do
          render PhlexIcons::Lucide::Pencil.new(class: 'w-[18px] h-[18px]')
        end
      end
    end

    def render_tank_card(variant: :mobile)
      render Vehicles::TankBalanceCardComponent.new(balance: tank[:balance], full: tank[:full], last_fill: tank[:last_fill], variant: variant)
    end

    def maintenances_section(limit: nil, variant: :mobile)
      div do
        div(class: 'flex items-center justify-between mb-2 px-1') do
          h3(class: 'text-sm font-semibold text-slate-700') { t('vehicle.maintenances.title') }
          span(class: 'text-xs text-slate-400') { t('vehicle.maintenances.by_km') }
        end
        maintenances_list(limit: limit, variant: variant)
      end
    end

    def maintenances_list(limit:, variant:)
      shown = limit ? maintenances.first(limit) : maintenances
      div(class: 'space-y-2') do
        if maintenances.empty?
          empty_row(t('vehicle.maintenances.empty'))
        else
          shown.each { |entry| render Vehicles::MaintenanceRowComponent.new(**entry.merge(variant: variant)) }
        end
        catalog_button(hidden: maintenances.size - shown.size)
      end
    end

    def catalog_button(hidden:)
      link_to(helpers.new_maintenance_path,
              class: 'w-full flex items-center justify-center gap-2 rounded-xl border border-dashed border-slate-300 bg-white/60 py-3 text-sm font-medium text-slate-600 hover:bg-white',
              data: { turbo_frame: 'modal' }) do
        render PhlexIcons::Lucide::CirclePlus.new(class: 'w-[17px] h-[17px]')
        plain t('vehicle.maintenances.add_from_catalog')
        if hidden.positive?
          span(class: 'text-slate-400') { " #{t('vehicle.maintenances.hidden_ok', count: hidden)}" }
        end
      end
    end

    def moves_section
      div do
        div(class: 'flex items-center justify-between mb-2 px-1') do
          h3(class: 'text-sm font-semibold text-slate-700') { t('vehicle.moves.title') }
          link_to(t('vehicle.moves.view_all'), helpers.new_refueling_path, class: 'text-xs font-medium text-blue-600', data: { turbo_frame: 'modal' })
        end
        moves_card
        p(class: 'text-[11px] text-slate-400 mt-1.5 px-1') { t('vehicle.moves.auto_debit') }
      end
    end

    def moves_card
      moves = tank[:moves]
      if moves.empty?
        empty_row(t('vehicle.moves.title'))
      else
        div(class: 'bg-white rounded-2xl border border-slate-100 overflow-hidden') do
          moves.each_with_index do |move, index|
            render Vehicles::TankMoveRowComponent.new(move: move, border: index < moves.size - 1)
          end
        end
      end
    end

    def insight_section
      insight = @payload[:insights].first
      return unless insight

      render Vehicles::InsightCardComponent.new(insight: insight)
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
          link_to(t('vehicle.edit'), helpers.edit_vehicle_path,
                  class: 'flex items-center gap-2 bg-white border border-slate-200 rounded-lg px-3 py-2 text-sm font-medium text-slate-700 hover:bg-slate-50',
                  data: { turbo_frame: 'modal' })
          link_to(t('vehicle.maintenances.add_from_catalog'), helpers.new_maintenance_path,
                  class: 'flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg px-4 py-2 text-sm font-semibold',
                  data: { turbo_frame: 'modal' })
        end
      end
    end

    def desktop_row_one
      div(class: 'grid grid-cols-12 gap-5') do
        div(class: 'col-span-12 lg:col-span-5') do
          render Vehicles::OdometerHeroComponent.new(current_km: odometer[:current_km], km_this_month: odometer[:km_this_month], updated_days_ago: odometer[:updated_days_ago], variant: :desktop)
        end
        div(class: 'col-span-12 lg:col-span-7') { render_tank_card }
      end
    end

    def desktop_row_two
      div(class: 'grid grid-cols-12 gap-5') do
        div(class: 'col-span-12 lg:col-span-7') { maintenances_section(variant: :desktop) }
        div(class: 'col-span-12 lg:col-span-5') { moves_section }
      end
    end

    def empty_row(message)
      div(class: 'bg-white rounded-2xl border border-slate-100 p-6 text-center text-sm text-slate-500') { message }
    end
  end
end
