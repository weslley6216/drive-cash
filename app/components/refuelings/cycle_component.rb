module Refuelings
  class CycleComponent < ApplicationComponent
    def initialize(cycle:)
      @cycle = cycle
    end

    def view_template
      div(id: "tank_cycle_#{@cycle.opener[:date].iso8601}") do
        header_row
        card
      end
    end

    private

    def header_row
      div(class: 'flex items-center justify-between mb-2 px-1 gap-2') do
        div(class: 'flex items-center gap-2 min-w-0') do
          h3(class: 'text-sm font-semibold text-slate-700 truncate') { title }
          atual_chip if @cycle.current
          km_per_liter_label if @cycle.km_per_liter
        end
        render CycleResultComponent.new(cycle: @cycle)
      end
    end

    def title
      t('vehicle.moves.cycle.title', date: helpers.l(@cycle.opener[:date], format: '%d %b'))
    end

    def atual_chip
      span(class: 'text-[10px] font-bold uppercase tracking-wide rounded-full px-2 py-0.5 border text-blue-700 bg-blue-50 border-blue-200') do
        t('vehicle.moves.cycle.current')
      end
    end

    def km_per_liter_label
      span(class: 'text-xs text-slate-400 whitespace-nowrap') do
        t('vehicle.moves.cycle.km_per_liter',
          value: helpers.number_with_precision(@cycle.km_per_liter, precision: 1, separator: ',', delimiter: '.'))
      end
    end

    def card
      div(class: 'bg-white rounded-xl shadow-sm border border-slate-100', data: { tank_filter_target: 'card' }) do
        @cycle.moves.each_with_index do |move, index|
          render Vehicles::TankMoveRowComponent.new(move: move, border: index < @cycle.moves.size - 1)
        end
      end
    end
  end
end
