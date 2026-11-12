module Analysis
  class BarChartComponent < ApplicationComponent
    include CardStyles
    PLOT_HEIGHT = 'h-[118px] lg:h-[206px]'.freeze
    BAR_WIDTH = { month: 'w-[5px] lg:w-3', day: 'w-[3px] lg:w-1.5' }.freeze
    DAY_LABELS = 8

    def initialize(bars:, month:, year:)
      @bars = bars
      @month = month
      @year = year
      @max_value = bars.reject { |row| row[:empty] }
        .flat_map { |row| [row[:earnings], row[:expenses]] }
        .max.to_f
    end

    def view_template
      section(class: "#{CARD} p-4 #{DESKTOP_FLAT} lg:p-6") do
        header
        @bars.empty? ? empty_state : chart
      end
    end

    private

    def header
      div(class: 'flex items-center justify-between mb-1') do
        div do
          h2(class: 'text-sm lg:text-base font-semibold text-slate-800') { I18n.t('analysis.show_view.bar_chart.title') }
          p(class: 'hidden lg:block text-xs text-slate-500 mt-0.5') { subtitle }
        end
        unless @bars.empty?
          div(class: 'flex items-center gap-3 text-[11px] lg:gap-4 lg:text-xs') do
            legend_item('bg-emerald-500', I18n.t('analysis.show_view.bar_chart.legend_earnings'))
            legend_item('bg-red-500', I18n.t('analysis.show_view.bar_chart.legend_expenses'))
          end
        end
      end
      p(class: 'text-xs text-slate-500 mb-3 lg:hidden') { subtitle }
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
      gap = daily? ? 'gap-0.5' : 'gap-[3px]'
      div(class: 'relative lg:mt-6', data: { controller: 'bar-tooltip' }) do
        tooltip_node
        div(class: "flex items-end justify-between #{gap}") do
          @bars.each_with_index { |bar_row, index| bar_column(bar_row, index) }
        end
      end
    end

    def daily?
      @bars.first[:unit] == :day
    end

    def bar_width
      BAR_WIDTH[daily? ? :day : :month]
    end

    def bar_column(bar_row, index)
      return future_bar_column(bar_row, index) if bar_row[:future]

      bar_row[:empty] ? empty_bar_column(bar_row, index) : data_bar_column(bar_row, index)
    end

    def column_classes
      'flex-1 min-w-0 flex flex-col items-center gap-1 pt-0.5 rounded-md'
    end

    def data_bar_column(bar_row, index)
      div(class: "#{column_classes} cursor-pointer", **column_data(bar_row, index)) do
        div(class: "flex items-end justify-center gap-px #{PLOT_HEIGHT}") do
          div(class: "rounded-t bg-emerald-500 #{bar_width}", data: { bar_tooltip_target: 'fill' }, style: "height: #{bar_share(bar_row[:earnings])}%")
          div(class: "rounded-t bg-red-500 #{bar_width}", data: { bar_tooltip_target: 'fill' }, style: "height: #{bar_share(bar_row[:expenses])}%")
        end
        bar_label(bar_row, index, 'text-slate-500')
      end
    end

    def empty_bar_column(bar_row, index)
      div(class: "#{column_classes} cursor-pointer", **column_data(bar_row, index)) do
        stub_bar
        bar_label(bar_row, index, 'text-slate-300')
      end
    end

    def future_bar_column(bar_row, index)
      div(class: 'flex-1 min-w-0 flex flex-col items-center gap-1 pt-0.5', aria_hidden: 'true', data: { future: 'true' }) do
        stub_bar
        bar_label(bar_row, index, 'text-slate-300')
      end
    end

    def stub_bar
      div(class: "flex items-end justify-center #{PLOT_HEIGHT}") do
        div(class: "rounded-full bg-slate-200 h-[3px] #{bar_width}", data: { bar_tooltip_target: 'fill' })
      end
    end

    def bar_label(bar_row, index, color)
      span(class: "text-[9px] leading-none min-h-[10px] #{color} font-medium") { label_shown?(index) ? bar_row[:label] : '' }
    end

    def label_shown?(index)
      return true unless daily?

      every = (@bars.size / DAY_LABELS.to_f).ceil
      (index % every).zero? || index == @bars.size - 1
    end

    def column_data(bar_row, index)
      {
        role:       'button',
        tabindex:   '0',
        aria_label: column_aria_label(bar_row),
        data:       {
          bar_tooltip_target: 'column',
          index:              index,
          label_text:         tooltip_label(bar_row),
          earn:               brl(bar_row[:earnings]),
          exp:                brl(bar_row[:expenses]),
          muted:              bar_row[:empty].to_s,
          action:             'mouseenter->bar-tooltip#show mouseleave->bar-tooltip#hide ' \
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
          data:  { bar_tooltip_target: 'tooltip' }) do
        div(class: 'relative bg-slate-900 text-white rounded-lg px-3 py-2 shadow-xl whitespace-nowrap', style: 'min-width: 124px') do
          p(class: 'text-[10px] font-semibold text-slate-400 mb-1 uppercase tracking-wide',
            data:  { bar_tooltip_target: 'label' })
          p(class: 'text-xs text-slate-400 hidden', data: { bar_tooltip_target: 'noData' }) do
            I18n.t('analysis.show_view.bar_chart.tooltip_no_data')
          end
          div(class: 'space-y-1', data: { bar_tooltip_target: 'values' }) do
            tooltip_row('bg-emerald-400', I18n.t('analysis.show_view.bar_chart.legend_earnings'), 'earnValue')
            tooltip_row('bg-red-400', I18n.t('analysis.show_view.bar_chart.legend_expenses'), 'expValue')
          end
          div(class: 'absolute left-1/2 bottom-0 w-2 h-2 bg-slate-900', style: 'transform: translate(-50%, 50%) rotate(45deg)')
        end
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

    def bar_share(value)
      return 0 if @max_value.zero? || value.to_f.zero?

      [(value.to_f / @max_value * 100).round(1), 1.5].max
    end

    def legend_item(color_class, label)
      span(class: 'flex items-center gap-1 lg:gap-1.5 text-slate-600 lg:text-slate-700') do
        span(class: "w-2 h-2 lg:w-2.5 lg:h-2.5 rounded-sm #{color_class}")
        plain label
      end
    end

    def empty_state
      p(class: 'text-sm text-slate-400 text-center py-6') { I18n.t('analysis.show_view.bar_chart.empty') }
    end
  end
end
