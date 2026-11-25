module Refuelings
  class MoveTableRowComponent < ApplicationComponent
    include TankMoveLabels

    def initialize(move:)
      @move = move
    end

    def view_template
      div(class: row_classes, data: { tank_filter_target: 'row', tank_filter_kind: filter_kind }) do
        span(class: 'text-slate-500 tabular-nums') { date_label }
        move_cell
        amount_cell
        balance_cell
      end
    end

    private

    def row_classes
      'grid grid-cols-[150px_minmax(0,1fr)_110px_120px] gap-4 px-5 py-3 items-center border-b border-slate-100 text-sm'
    end

    def move_cell
      span(class: 'flex items-center gap-2.5 min-w-0') do
        icon_block
        span(class: label_classes) { label }
        span(class: sub_label_classes) { sub_label }
      end
    end

    def icon_block
      tone = credit? ? 'bg-blue-50 text-blue-600' : 'bg-red-50 text-red-600'
      span(class: "w-7 h-7 rounded-md #{tone} flex items-center justify-center flex-shrink-0") do
        icon = credit? ? PhlexIcons::Lucide::Fuel : PhlexIcons::Lucide::Route
        render icon.new(class: 'w-[14px] h-[14px]')
      end
    end

    def label_classes
      credit? ? 'font-medium text-slate-800' : 'font-medium text-slate-800 truncate'
    end

    def sub_label_classes
      credit? ? 'text-slate-400 text-xs truncate' : 'text-slate-400 text-xs'
    end

    def amount_cell
      span(class: "text-right font-semibold tabular-nums #{amount_tone}") { "#{amount_sign}#{format_currency(@move[:amount].abs)}" }
    end

    def balance_cell
      span(class: balance_classes) { balance_text }
    end

    def balance_classes
      balance_after.negative? ? 'text-right tabular-nums text-red-700 font-semibold' : 'text-right tabular-nums text-slate-600'
    end

    def balance_text
      balance_after.negative? ? "−#{format_currency(balance_after.abs)}" : format_currency(balance_after)
    end

    def balance_after
      @move[:balance_after]
    end
  end
end
