module Refuelings
  class TankFilterComponent < ApplicationComponent
    FILTERS = %w[all fill route].freeze
    ACTIVE_CLASSES = 'bg-white text-slate-900 shadow-sm'.freeze
    INACTIVE_CLASSES = 'text-slate-500'.freeze

    def initialize(variant: :mobile)
      @variant = variant
    end

    def view_template
      div(role: 'tablist', class: "flex gap-1 p-1 rounded-xl bg-slate-200/60 #{desktop? ? 'w-auto' : 'w-full'}") do
        FILTERS.each_with_index { |kind, index| tab(kind, selected: index.zero?) }
      end
    end

    private

    def desktop?
      @variant == :desktop
    end

    def tab(kind, selected:)
      button(type: 'button', role: 'tab', aria: { selected: selected.to_s }, class: tab_classes(selected),
             data: { action: 'tank-filter#select', tank_filter_target: 'tab', tank_filter_kind_param: kind }) do
        t("vehicle.moves.filters.#{kind}")
      end
    end

    def tab_classes(selected)
      base = "#{desktop? ? 'px-4' : 'flex-1'} h-9 rounded-lg text-xs font-semibold"
      "#{base} #{selected ? ACTIVE_CLASSES : INACTIVE_CLASSES}"
    end
  end
end
