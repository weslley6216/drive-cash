module History
  class MonthBarsComponent < ApplicationComponent
    SIZES = {
      trend: { box: 'h-[70px] lg:h-[54px]', bar: 'h-[max(3px,calc(var(--bar)*56px))] lg:h-[max(3px,calc(var(--bar)*40px))]' },
      year:  { box: 'h-[78px] lg:h-[94px]', bar: 'h-[max(3px,calc(var(--bar)*64px))] lg:h-[max(3px,calc(var(--bar)*80px))]' }
    }.freeze

    def initialize(months:, earnings:, highlighted:, size: :trend)
      @months = months
      @earnings = earnings
      @highlighted = highlighted
      @size = size
    end

    def view_template
      div(class: "flex items-end gap-1.5 #{SIZES[@size][:box]}") do
        @months.each_with_index { |month, index| bar(month, index) }
      end
    end

    private

    def bar(month, index)
      div(class: 'flex-1 flex flex-col items-center gap-1') do
        div(class: "w-full rounded-t #{SIZES[@size][:bar]} #{bar_classes(index)}", data: { trend_bar: true },
            style: "--bar: #{ratio(month[:total])}")
        span(class: "text-[9px] #{index == @months.size - 1 ? 'font-bold text-slate-700' : 'text-slate-400'}",
             data:  { trend_label: true }) { month_abbr(month[:month]) }
      end
    end

    def bar_classes(index)
      base, strong = @earnings ? %w[bg-emerald-200 bg-emerald-600] : %w[bg-red-200 bg-red-600]
      @highlighted.include?(index) ? strong : base
    end

    def ratio(total)
      max = @months.map { |month| month[:total] }.max.to_f
      return 0.0 if max.zero?

      (total / max).round(2)
    end

    def month_abbr(month) = I18n.t('date.abbr_month_names')[month]
  end
end
