module Refuelings
  class IndexView < ApplicationView
    def initialize(moves:, cadence:)
      @moves = moves
      @cadence = cadence
    end

    def view_template
      render LayoutComponent.new(title: t('vehicle.moves.page_title'), bottom_nav: :more, sidebar_nav: :vehicle) do
        div(id: 'flash') { render FlashComponent.new(flash: helpers.flash) }
        header_section
        cadence_section
        moves_section
        turbo_frame_tag 'modal'
      end
    end

    private

    def header_section
      div(class: 'mb-4 flex items-center justify-between') do
        div do
          h1(class: 'text-xl lg:text-2xl font-bold text-slate-900') { t('vehicle.moves.page_title') }
          p(class: 'text-sm text-slate-500') { t('vehicle.moves.page_subtitle') }
        end
        link_to(helpers.new_refueling_path,
                class: 'flex items-center gap-1.5 rounded-xl px-3.5 py-2 text-xs font-semibold text-white bg-blue-600 hover:bg-blue-700',
                data:  { turbo_frame: 'modal' }) do
          render PhlexIcons::Lucide::Plus.new(class: 'w-[15px] h-[15px]')
          plain t('vehicle.tank.refuel')
        end
      end
    end

    def cadence_section
      div(class: 'bg-white rounded-2xl border border-slate-100 p-4 mb-4 flex items-center gap-3') do
        div(class: 'w-9 h-9 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center') do
          render PhlexIcons::Lucide::CalendarClock.new(class: 'w-[18px] h-[18px]')
        end
        p(class: 'text-sm font-medium text-slate-700') { cadence_text }
      end
    end

    def cadence_text
      count = @cadence[:average_days]
      return t('vehicle.moves.cadence.unknown') unless count

      t('vehicle.moves.cadence', count: count)
    end

    def moves_section
      if @moves.empty?
        div(class: 'bg-white rounded-2xl border border-slate-100 p-6 text-center text-sm text-slate-500') do
          plain t('vehicle.moves.empty')
        end
      else
        div(class: 'bg-white rounded-2xl border border-slate-100 overflow-hidden') do
          @moves.each_with_index do |move, index|
            render Vehicles::TankMoveRowComponent.new(move: move, border: index < @moves.size - 1)
          end
        end
      end
    end
  end
end
