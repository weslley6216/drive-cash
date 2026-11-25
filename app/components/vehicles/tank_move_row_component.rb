module Vehicles
  class TankMoveRowComponent < ApplicationComponent
    include TankMoveLabels

    def initialize(move:, border: true)
      @move = move
      @border = border
    end

    def view_template
      div(class: row_classes, data: { tank_filter_target: 'row', tank_filter_kind: filter_kind }) do
        icon_block
        info_block
        amount_block
      end
    end

    private

    def row_classes
      base = 'flex items-center gap-3 px-4 py-3'
      @border ? "#{base} border-b border-slate-100" : base
    end

    def icon_block
      tone = credit? ? 'bg-blue-50 text-blue-600' : 'bg-red-50 text-red-600'
      div(class: "w-10 h-10 rounded-lg flex items-center justify-center flex-shrink-0 #{tone}") do
        icon = credit? ? PhlexIcons::Lucide::Fuel : PhlexIcons::Lucide::Route
        render icon.new(class: 'w-[18px] h-[18px]')
      end
    end

    def info_block
      div(class: 'flex-1 min-w-0') do
        p(class: 'text-sm font-semibold text-slate-800 truncate') { label }
        p(class: 'text-xs text-slate-500 truncate') { "#{date_label} · #{sub_label}" }
      end
    end

    def amount_block
      span(class: "text-sm font-semibold tabular-nums whitespace-nowrap #{amount_tone}") do
        "#{amount_sign}#{format_currency(@move[:amount].abs)}"
      end
    end
  end
end
