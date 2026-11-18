module History
  class SliceTrendComponent < ApplicationComponent
    include CardStyles

    def initialize(trend:)
      @trend = trend
    end

    def view_template
      div(class: "#{CARD} p-4 order-first lg:order-last", data: { slice_summary: 'trend' }) do
        header
        bars
        comparison if @trend[:change]
      end
    end

    private

    def header
      div(class: 'flex items-center justify-between mb-2') do
        p(class: 'text-[10px] font-bold uppercase tracking-wider text-slate-500') { t("history.index.slice_summary.trend_title.#{@trend[:kind]}") }
      end
    end

    def bars
      div(class: 'flex items-end gap-1.5 h-14 lg:h-10') do
        @trend[:months].each_with_index { |month, index| bar(month, index) }
      end
    end

    def bar(month, index)
      selected = index == @trend[:months].size - 1
      div(class: 'flex-1 flex flex-col items-center gap-1 h-full justify-end') do
        div(class: "w-full rounded-t #{bar_classes(selected)}", data: { trend_bar: true }, style: "height: max(3px, #{percentage(month[:total])}%)")
        span(class: "text-[9px] #{selected ? 'font-bold text-slate-700' : 'text-slate-400'}", data: { trend_label: true }) { month_abbr(month[:month]) }
      end
    end

    def bar_classes(selected)
      base, strong = earnings? ? %w[bg-emerald-200 bg-emerald-600] : %w[bg-red-200 bg-red-600]
      selected ? strong : base
    end

    def percentage(total)
      max = @trend[:months].map { |month| month[:total] }.max.to_f
      return 0 if max.zero?

      (total / max * 100).round
    end

    def month_abbr(month) = I18n.t('date.abbr_month_names')[month]

    def comparison
      p(class: 'text-[11px] text-slate-500 mt-1') do
        change_span
        plain " #{t('history.index.slice_summary.versus', month: previous_month_name)}"
        plain " · #{t('history.index.slice_summary.in_progress')}" if @trend[:in_progress]
      end
    end

    def change_span
      span(class: class_names('font-semibold', rising_expense? ? 'text-red-700' : 'text-slate-700'), data: { trend_change: true }) { change_text }
    end

    def change_text
      value = @trend[:change]
      sign = value.negative? ? '−' : '+'
      "#{sign}#{value.abs.round}%"
    end

    def rising_expense?
      !earnings? && @trend[:change].positive?
    end

    def earnings?
      @trend[:kind] == :earnings
    end

    def previous_month_name
      previous_month = @trend[:months][-2][:month]
      I18n.t('date.month_names')[previous_month]
    end
  end
end
