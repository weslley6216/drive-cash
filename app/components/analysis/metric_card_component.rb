module Analysis
  class MetricCardComponent < ApplicationComponent
    def initialize(label:, icon:, value:, series:, variant: :compact, class_name: nil)
      @label = label
      @icon = icon
      @value = value
      @series = series
      @variant = variant
      @class_name = class_name
    end

    def view_template
      hero? ? hero_card : compact_card
    end

    private

    def hero?
      @variant == :hero
    end

    def trend?
      @series[:points].size >= Dashboard::MetricsSeries::MIN_POINTS
    end

    def hero_card
      div(class: 'bg-white rounded-xl shadow-sm border border-blue-100 p-4 lg:p-5') do
        div(class: 'flex items-center gap-2 text-blue-600 mb-1') do
          render @icon.new(class: 'lucide w-[14px] h-[14px]')
          span(class: 'text-xs font-semibold') { @label }
        end
        p(class: 'font-bold text-slate-900 text-2xl lg:text-3xl') { @value }

        if trend?
          div(class: 'mt-2 lg:min-w-[300px]') { render sparkline(color: '#2563eb', height: 34, height_class: 'h-[34px] lg:h-9', fill: true) }
          trend_footer(big: true)
        else
          p(class: 'text-[11px] text-slate-400 mt-1.5') { t('analysis.show_view.trend.not_enough') }
        end
      end
    end

    def compact_card
      div(class: class_names('bg-white rounded-xl shadow-sm border border-slate-100 min-w-0 p-3.5 lg:p-5', @class_name)) do
        div(class: 'flex items-center gap-1.5 text-slate-500 mb-1') do
          render @icon.new(class: 'lucide w-3 h-3')
          span(class: 'text-[11px] font-medium truncate') { @label }
        end
        p(class: 'font-bold text-slate-800 text-[15px] lg:text-2xl') { @value }

        if trend?
          div(class: 'mt-1.5 lg:min-w-[160px]') { render sparkline(color: '#94a3b8', height: 20, height_class: 'h-5', fill: false) }
          trend_footer(big: false)
        end
      end
    end

    def sparkline(color:, height:, height_class:, fill:)
      values = @series[:points].map { |point| point[:value] }
      SparklineComponent.new(values: values, color: color, height: height, height_class: height_class, fill: fill)
    end

    def trend_footer(big:)
      points = @series[:points]
      best = @series[:best]

      div(class: "flex justify-between gap-2 text-slate-400 mt-1 #{big ? 'text-[11px]' : 'text-[10px]'}") do
        span { month_abbr(points.first[:month]) }
        span(class: 'truncate') { best_label(best, big: big) }
        span(class: 'font-semibold text-blue-600') { month_abbr(points.last[:month]) }
      end
    end

    def best_label(best, big:)
      label = t('analysis.show_view.trend.best', month: month_abbr(best[:month]).downcase)
      big ? "#{label} · #{format_currency(best[:value])}" : label
    end
  end
end
