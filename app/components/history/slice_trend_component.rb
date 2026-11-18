module History
  class SliceTrendComponent < ApplicationComponent
    include CardStyles

    def initialize(trend:, slice:, query:)
      @trend = trend
      @slice = slice
      @query = query
    end

    def view_template
      div(class: "#{CARD} p-4 grid grid-cols-[1fr_auto] order-first lg:order-last lg:px-5 lg:py-3", data: { slice_summary: 'trend' }) do
        header
        bars
        comparison if @trend[:change]
      end
    end

    private

    def header
      div(class: 'col-span-2 flex items-center justify-between mb-2 lg:col-span-1 lg:mb-1 lg:items-start') do
        p(class: 'text-[10px] font-bold uppercase tracking-wider text-slate-500') { t("history.index.slice_summary.trend_title.#{@trend[:kind]}") }
        div(class: 'lg:hidden') { render ModeToggleComponent.new(slice: @slice, query: @query) }
      end
    end

    def bars
      div(class: 'col-span-2') do
        render MonthBarsComponent.new(months: @trend[:months], earnings: earnings?, highlighted: [@trend[:months].size - 1])
      end
    end

    def comparison
      p(class: 'col-span-2 text-[11px] text-slate-500 mt-1 lg:col-span-1 lg:col-start-2 lg:row-start-1 lg:mt-0 lg:mb-1') do
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
