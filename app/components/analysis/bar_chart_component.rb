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
      div(class: 'relative', data: { controller: 'bar-tooltip' }) do
        tooltip_node
        div(class: "flex items-end #{gap}", style: 'height: 140px') do
          @bars.each_with_index { |bar_row, index| bar_column(bar_row, index) }
        end
      end
    end

    def bar_column(bar_row, index)
      bar_row[:empty] ? empty_bar_column(bar_row, index) : data_bar_column(bar_row, index)
    end

    def data_bar_column(bar_row, index)
      earn_height = bar_height(bar_row[:earnings])
      exp_height  = bar_height(bar_row[:expenses])

      div(class: 'flex-1 min-w-0 flex flex-col gap-0.5 cursor-pointer rounded', **column_data(bar_row, index)) do
        div(class: 'flex items-end gap-px', style: "height: #{CHART_HEIGHT}px") do
          div(class: 'flex-1 min-w-0 rounded-t bg-emerald-500', data: { bar_tooltip_target: 'fill' }, style: "height: #{earn_height}px")
          div(class: 'flex-1 min-w-0 rounded-t bg-red-500',     data: { bar_tooltip_target: 'fill' }, style: "height: #{exp_height}px")
        end
        span(class: 'block overflow-hidden text-center text-[10px] text-slate-500 font-medium') { bar_row[:label] }
      end
    end

    def empty_bar_column(bar_row, index)
      div(class: 'flex-1 min-w-0 flex flex-col gap-0.5 cursor-pointer rounded', **column_data(bar_row, index)) do
        div(class: 'flex items-end gap-px', style: "height: #{CHART_HEIGHT}px") do
          div(class: 'flex-1 min-w-0 rounded-t bg-slate-200', data: { bar_tooltip_target: 'fill' }, style: "height: #{STUB_HEIGHT}px")
          div(class: 'flex-1 min-w-0 rounded-t bg-slate-200', data: { bar_tooltip_target: 'fill' }, style: "height: #{STUB_HEIGHT}px")
        end
        span(class: 'block overflow-hidden text-center text-[10px] text-slate-300 font-medium') { bar_row[:label] }
      end
    end

    def column_data(bar_row, index)
      {
        role: 'button',
        tabindex: '0',
        aria_label: column_aria_label(bar_row),
        data: {
          bar_tooltip_target: 'column',
          index: index,
          label_text: tooltip_label(bar_row),
          earn: brl(bar_row[:earnings]),
          exp: brl(bar_row[:expenses]),
          muted: bar_row[:empty].to_s,
          action: 'mouseenter->bar-tooltip#show mouseleave->bar-tooltip#hide ' \
                  'click->bar-tooltip#toggle keydown.enter->bar-tooltip#toggle'
        }
      }
    end

    def column_aria_label(bar_row)
      return "#{tooltip_label(bar_row)}: #{I18n.t('analysis.show_view.bar_chart.tooltip_no_data')}" if bar_row[:empty]

      earnings_label = I18n.t('analysis.show_view.bar_chart.legend_earnings')
      expenses_label = I18n.t('analysis.show_view.bar_chart.legend_expenses')
      "#{tooltip_label(bar_row)}: #{earnings_label} #{brl(bar_row[:earnings])}, " \
        "#{expenses_label} #{brl(bar_row[:expenses])}"
    end

    def tooltip_label(bar_row)
      if bar_row[:unit] == :day
        I18n.t('analysis.show_view.bar_chart.tooltip_day_label', day: bar_row[:label])
      else
        bar_row[:label]
      end
    end

    def tooltip_node
      div(class: 'absolute z-20 -translate-x-1/2 -translate-y-full pointer-events-none hidden',
          style: "top: #{CHART_HEIGHT - 4}px",
          data: { bar_tooltip_target: 'tooltip' }) do
        div(class: 'bg-slate-900 text-white rounded-lg px-3 py-2 shadow-xl whitespace-nowrap', style: 'min-width: 124px') do
          p(class: 'text-[10px] font-semibold text-slate-400 mb-1 uppercase tracking-wide',
            data: { bar_tooltip_target: 'label' })
          p(class: 'text-xs text-slate-400 hidden', data: { bar_tooltip_target: 'noData' }) do
            I18n.t('analysis.show_view.bar_chart.tooltip_no_data')
          end
          div(class: 'space-y-1', data: { bar_tooltip_target: 'values' }) do
            tooltip_row('bg-emerald-400', I18n.t('analysis.show_view.bar_chart.legend_earnings'), 'earnValue')
            tooltip_row('bg-red-400',     I18n.t('analysis.show_view.bar_chart.legend_expenses'), 'expValue')
          end
        end
        div(class: 'w-2 h-2 bg-slate-900 rotate-45 mx-auto', style: 'margin-top: -4px',
            data: { bar_tooltip_target: 'arrow' })
      end
    end

    def tooltip_row(dot_class, label, value_target)
      div(class: 'flex items-center gap-2 text-xs') do
        span(class: "w-1.5 h-1.5 rounded-full #{dot_class}")
        span(class: 'text-slate-300') { label }
        span(class: 'font-semibold tabular-nums ml-auto', data: { bar_tooltip_target: value_target })
      end
    end

    def brl(value)
      helpers.number_to_currency(value, unit: 'R$ ', format: '%u%n', separator: ',', delimiter: '.', precision: 2)
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
