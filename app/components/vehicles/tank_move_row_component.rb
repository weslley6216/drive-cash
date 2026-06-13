module Vehicles
  class TankMoveRowComponent < ApplicationComponent
    def initialize(move:, border: true)
      @move = move
      @border = border
    end

    def view_template
      div(class: row_classes) do
        icon_block
        info_block
        amount_block
      end
    end

    private

    def credit?
      @move[:kind] == :credit
    end

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

    def label
      return t('vehicle.moves.full_tank') if credit?

      @move[:description].presence || t('vehicle.moves.route')
    end

    def sub_label
      return fill_detail if credit?

      t('vehicle.moves.fuel_expense')
    end

    def fill_detail
      parts = [@move[:vendor]].compact
      parts << "#{helpers.number_with_precision(@move[:liters], precision: 1, separator: ',', delimiter: '.')} L" if @move[:liters]
      parts << "#{format_currency(@move[:price_per_liter])}/L" if @move[:price_per_liter]
      parts.join(' · ')
    end

    def date_label
      date = @move[:date]
      return t('vehicle.moves.today') if date == Date.current
      return t('vehicle.moves.yesterday') if date == Date.current - 1

      helpers.l(date, format: '%d %b')
    end

    def amount_block
      tone = credit? ? 'text-blue-700' : 'text-red-700'
      sign = credit? ? '+' : '−'
      span(class: "text-sm font-semibold tabular-nums whitespace-nowrap #{tone}") do
        "#{sign}#{format_currency(@move[:amount].abs)}"
      end
    end
  end
end
