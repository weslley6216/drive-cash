module Analysis
  class BarChartComponent < ApplicationComponent
    CHART_HEIGHT = 130

    def initialize(months:)
      @months = months
      @max_value = months.flat_map { |row| [row[:earnings], row[:expenses]] }.max.to_f
    end

    def view_template
      section(class: 'bg-white rounded-xl shadow-sm border border-slate-100 p-4') do
        header
        @months.empty? ? empty_state : chart
      end
    end

    private

    def header
      div(class: 'flex items-center justify-between mb-1') do
        h2(class: 'text-sm font-semibold text-slate-800') { I18n.t('analysis.show_view.bar_chart.title') }
        unless @months.empty?
          div(class: 'flex items-center gap-3 text-[11px]') do
            legend_item('bg-emerald-400', I18n.t('analysis.show_view.bar_chart.legend_earnings'))
            legend_item('bg-red-400',     I18n.t('analysis.show_view.bar_chart.legend_expenses'))
          end
        end
      end
      p(class: 'text-xs text-slate-500 mb-3') { I18n.t('analysis.show_view.bar_chart.subtitle') }
    end

    def chart
      div(class: 'flex items-end justify-between gap-2', style: 'height: 140px') do
        @months.each { |month_row| month_column(month_row) }
      end
    end

    def month_column(month_row)
      earn_height = bar_height(month_row[:earnings])
      exp_height  = bar_height(month_row[:expenses])

      div(class: 'flex-1 flex flex-col items-center gap-1') do
        div(class: 'flex items-end gap-0.5', style: "height: #{CHART_HEIGHT}px") do
          div(class: 'w-3 rounded-t bg-emerald-500', style: "height: #{earn_height}px")
          div(class: 'w-3 rounded-t bg-red-500',     style: "height: #{exp_height}px")
        end
        span(class: 'text-[10px] text-slate-500 font-medium') { month_row[:label] }
      end
    end

    def bar_height(value)
      return 0 if @max_value.zero?

      (value.to_f / @max_value * CHART_HEIGHT).round
    end

    def legend_item(color_class, label)
      span(class: 'flex items-center gap-1 text-slate-600') do
        span(class: "w-2 h-2 rounded-sm #{color_class}")
        plain label
      end
    end

    def empty_state
      p(class: 'text-sm text-slate-400 text-center py-6') { I18n.t('analysis.show_view.bar_chart.empty') }
    end
  end
end
