module Analysis
  class BarChartComponent < ApplicationComponent
    CHART_HEIGHT = 130
    STUB_HEIGHT  = 3

    def initialize(bars:, month:, year:)
      @bars  = bars
      @month = month
      @year  = year
      @max_value = bars.reject { |row| row[:empty] }
                       .flat_map { |row| [row[:earnings], row[:expenses]] }
                       .max.to_f
    end

    def view_template
      section(class: 'bg-white rounded-xl shadow-sm border border-slate-100 p-4') do
        header
        @bars.empty? ? empty_state : chart
      end
    end

    private

    def header
      div(class: 'flex items-center justify-between mb-1') do
        h2(class: 'text-sm font-semibold text-slate-800') { I18n.t('analysis.show_view.bar_chart.title') }
        unless @bars.empty?
          div(class: 'flex items-center gap-3 text-[11px]') do
            legend_item('bg-emerald-400', I18n.t('analysis.show_view.bar_chart.legend_earnings'))
            legend_item('bg-red-400',     I18n.t('analysis.show_view.bar_chart.legend_expenses'))
          end
        end
      end
      p(class: 'text-xs text-slate-500 mb-3') { subtitle }
    end

    def subtitle
      if @month
        month_name = I18n.t('date.month_names')[@month].capitalize
        I18n.t('analysis.show_view.bar_chart.subtitle_monthly', month_name: month_name, year: @year)
      else
        I18n.t('analysis.show_view.bar_chart.subtitle_annual', year: @year)
      end
    end

    def chart
      gap = @bars.size > 15 ? 'gap-1' : 'gap-2'
      div(class: "flex items-end #{gap}", style: 'height: 140px') do
        @bars.each { |bar_row| bar_column(bar_row) }
      end
    end

    def bar_column(bar_row)
      bar_row[:empty] ? empty_bar_column(bar_row) : data_bar_column(bar_row)
    end

    def data_bar_column(bar_row)
      earn_height = bar_height(bar_row[:earnings])
      exp_height  = bar_height(bar_row[:expenses])

      div(class: 'flex-1 min-w-0 flex flex-col gap-0.5') do
        div(class: 'flex items-end gap-px', style: "height: #{CHART_HEIGHT}px") do
          div(class: 'flex-1 min-w-0 rounded-t bg-emerald-500', style: "height: #{earn_height}px")
          div(class: 'flex-1 min-w-0 rounded-t bg-red-500',     style: "height: #{exp_height}px")
        end
        span(class: 'block overflow-hidden text-center text-[10px] text-slate-500 font-medium') { bar_row[:label] }
      end
    end

    def empty_bar_column(bar_row)
      div(class: 'flex-1 min-w-0 flex flex-col gap-0.5') do
        div(class: 'flex items-end gap-px', style: "height: #{CHART_HEIGHT}px") do
          div(class: 'flex-1 min-w-0 rounded-t bg-slate-200', style: "height: #{STUB_HEIGHT}px")
          div(class: 'flex-1 min-w-0 rounded-t bg-slate-200', style: "height: #{STUB_HEIGHT}px")
        end
        span(class: 'block overflow-hidden text-center text-[10px] text-slate-300 font-medium') { bar_row[:label] }
      end
    end

    def bar_height(value)
      return 0 if @max_value.zero?

      [(value.to_f / @max_value * CHART_HEIGHT).round, 1].max
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
