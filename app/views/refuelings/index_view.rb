module Refuelings
  class IndexView < ApplicationView
    include TopbarStyles

    def initialize(cycles:, vehicle:, unread_count:)
      @cycles = cycles
      @vehicle = vehicle
      @unread_count = unread_count
    end

    def view_template
      render LayoutComponent.new(title: t('vehicle.moves.page_title'), bottom_nav: :more, sidebar_nav: :vehicle) do
        render ScreenComponent.new do |screen|
          screen.with_header do
            mobile_header
            desktop_topbar
          end
          screen.with_content { content }
        end
        turbo_frame_tag 'modal'
      end
    end

    private

    def mobile_header
      div(class: "#{PHONE_BAR} flex items-start justify-between gap-3 lg:hidden") do
        div(class: 'flex items-start gap-2 min-w-0 flex-1') do
          render BackLinkComponent.new(fallback: helpers.vehicle_path, label: t('vehicle.moves.back'))
          div(class: 'min-w-0') do
            h1(class: 'text-2xl font-bold text-slate-800 leading-tight text-balance') { t('vehicle.moves.page_title') }
            p(class: 'text-sm text-slate-500 mt-0.5') { t('vehicle.moves.page_subtitle') }
          end
        end
        div(class: 'mt-1') { mobile_refuel_button }
      end
    end

    def mobile_refuel_button
      link_to(helpers.new_refueling_path,
              class: 'flex-shrink-0 flex items-center gap-1.5 bg-blue-600 hover:bg-blue-700 text-white font-semibold ' \
                     'rounded-xl px-3.5 h-9 text-xs',
              data:  { turbo_frame: 'modal' }) do
        render PhlexIcons::Lucide::Plus.new(class: 'w-[15px] h-[15px]')
        plain t('vehicle.tank.refuel')
      end
    end

    def desktop_topbar
      render DesktopTopbarComponent.new(
        title:        t('vehicle.moves.page_title'),
        subtitle:     t('vehicle.moves.desktop_subtitle', subtitle: t('vehicle.moves.page_subtitle'), vehicle: vehicle_subtitle),
        unread_count: @unread_count,
        back:         { label: t('vehicle.title'), path: helpers.vehicle_path }
      ) do |topbar|
        topbar.with_actions { desktop_refuel_button }
      end
    end

    def desktop_refuel_button
      link_to(helpers.new_refueling_path,
              class: 'flex items-center gap-1.5 bg-blue-600 hover:bg-blue-700 text-white font-semibold rounded-lg px-4 py-2 text-sm',
              data:  { turbo_frame: 'modal' }) do
        render PhlexIcons::Lucide::Plus.new(class: 'w-4 h-4')
        plain t('vehicle.tank.refuel')
      end
    end

    def vehicle_subtitle
      t('vehicle.subtitle', brand: @vehicle.brand, vehicle_model: @vehicle.vehicle_model, year: @vehicle.year)
    end

    def content
      @cycles.empty? ? empty_state : moves_layout
    end

    def empty_state
      div(class: 'lg:bg-white lg:rounded-xl lg:border lg:border-slate-200 lg:max-w-3xl') do
        render EmptyStateComponent.new(icon: PhlexIcons::Lucide::Fuel, icon_color: 'text-blue-600', ring: 'bg-blue-50 border-blue-100',
                                       title: t('vehicle.moves.empty.title'), description: t('vehicle.moves.empty.description'),
                                       cta_label: t('vehicle.moves.empty.cta'), cta_path: helpers.new_refueling_path,
                                       cta_icon: PhlexIcons::Lucide::Plus, cta_data: { turbo_frame: 'modal' })
      end
    end

    def current_cycle
      @cycles.first
    end

    def moves_layout
      div(data: { controller: 'tank-filter' }) do
        mobile_moves
        desktop_moves
      end
    end

    def mobile_moves
      div(class: 'lg:hidden space-y-4') do
        render Refuelings::BalanceCardComponent.new(balance: current_cycle.closing_balance, full: current_cycle.opener[:amount],
                                                    since: current_cycle.opener[:date])
        render Refuelings::TankFilterComponent.new
        @cycles.each { |cycle| render Refuelings::CycleComponent.new(cycle: cycle) }
        p(class: 'text-[11px] text-slate-400 px-1') { t('vehicle.moves.footnote') }
      end
    end

    def desktop_moves
      div(class: 'hidden lg:grid grid-cols-12 gap-6 items-start') do
        div(class: 'col-span-12 lg:col-span-8 space-y-5') do
          render Refuelings::TankFilterComponent.new(variant: :desktop)
          desktop_table
        end
        div(class: 'col-span-12 lg:col-span-4 space-y-4') do
          render Refuelings::BalanceCardComponent.new(balance: current_cycle.closing_balance, full: current_cycle.opener[:amount],
                                                      since: current_cycle.opener[:date], variant: :desktop)
          p(class: 'text-xs text-slate-500 leading-relaxed px-1') { t('vehicle.moves.footnote_desktop') }
        end
      end
    end

    def desktop_table
      div(class: 'bg-white rounded-xl border border-slate-200 overflow-hidden') do
        desktop_table_header
        @cycles.each { |cycle| desktop_cycle_rows(cycle) }
      end
    end

    def desktop_table_header
      div(class: 'grid grid-cols-[150px_minmax(0,1fr)_110px_120px] gap-4 px-5 py-3 text-[11px] font-bold uppercase ' \
                 'tracking-wider text-slate-400 border-b border-slate-100') do
        span { t('vehicle.moves.table.date') }
        span { t('vehicle.moves.table.move') }
        span(class: 'text-right') { t('vehicle.moves.table.amount') }
        span(class: 'text-right') { t('vehicle.moves.table.balance_after') }
      end
    end

    def desktop_cycle_rows(cycle)
      div(class: 'flex items-center justify-between px-5 py-2.5 bg-slate-50 border-b border-slate-100') do
        div(class: 'flex items-center gap-2') do
          span(class: 'text-xs font-semibold text-slate-700') { t('vehicle.moves.cycle.title', date: helpers.l(cycle.opener[:date], format: '%d %b')) }
          desktop_atual_chip if cycle.current
          span(class: 'text-xs text-slate-400') { desktop_km_per_liter_text(cycle) } if cycle.km_per_liter
        end
        render Refuelings::CycleResultComponent.new(cycle: cycle)
      end
      cycle.moves.each { |move| render Refuelings::MoveTableRowComponent.new(move: move) }
    end

    def desktop_atual_chip
      span(class: 'text-[10px] font-bold uppercase tracking-wide rounded-full px-2 py-0.5 border text-blue-700 bg-blue-50 border-blue-200') do
        t('vehicle.moves.cycle.current')
      end
    end

    def desktop_km_per_liter_text(cycle)
      t('vehicle.moves.cycle.km_per_liter',
        value: helpers.number_with_precision(cycle.km_per_liter, precision: 1, separator: ',', delimiter: '.'))
    end
  end
end
