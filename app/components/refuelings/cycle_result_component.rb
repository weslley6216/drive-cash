module Refuelings
  class CycleResultComponent < ApplicationComponent
    def initialize(cycle:)
      @cycle = cycle
    end

    def view_template
      span(class: classes) { text }
    end

    private

    def classes
      return 'text-xs font-semibold text-slate-700 tabular-nums' if @cycle.current
      return 'text-xs font-semibold text-red-700 tabular-nums' if @cycle.closing_balance.negative?

      'text-xs font-medium text-slate-500 tabular-nums'
    end

    def text
      return t('vehicle.moves.cycle.remaining', amount: format_currency(@cycle.closing_balance)) if @cycle.current
      return t('vehicle.moves.cycle.over', amount: "−#{format_currency(@cycle.closing_balance.abs)}") if @cycle.closing_balance.negative?

      t('vehicle.moves.cycle.closed', amount: format_currency(@cycle.closing_balance))
    end
  end
end
