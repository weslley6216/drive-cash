module Analysis
  class ShowView < ApplicationView
    METRIC_ICONS = {
      per_day:  PhlexIcons::Lucide::Zap,
      per_trip: PhlexIcons::Lucide::Package,
      per_hour: PhlexIcons::Lucide::Clock,
      margin:   PhlexIcons::Lucide::Gauge
    }.freeze

    def initialize(insights:, filters:)
      @insights = insights
      @filters = filters
    end

    def view_template
      render LayoutComponent.new(
        title: t('.title'),
        bottom_nav: :analysis,
        sidebar_nav: :analysis,
        app_shell: true
      ) do
        div(id: 'flash', class: 'flex-none') { render FlashComponent.new(flash: helpers.flash) }

        pinned_topbar
        content_scroll_region

        turbo_frame_tag 'modal'
      end
    end

    private

    def pinned_topbar
      div(class: 'flex-none px-4 sm:px-6 pt-4') { topbar }
    end

    def content_scroll_region
      div(class: 'flex-1 min-h-0 overflow-y-auto px-4 sm:px-6 pt-2 pb-24 lg:pb-6') do
        metrics_grid
        bar_chart_section
        breakdown_section
        insights_section
      end
    end

    def topbar
      div(class: 'flex items-center justify-between gap-4') do
        div do
          h1(class: 'text-2xl lg:text-3xl font-bold text-slate-900 tracking-tight') { t('.title') }
          p(class: 'text-sm text-slate-500 mt-0.5') { subtitle }
        end

        render FilterComponent.new(
          selected_year: @filters[:year],
          selected_month: @filters[:month],
          available_years: @filters[:available_years],
          popover: true,
          action_path: helpers.analysis_path
        )
      end
    end

    def subtitle
      if @filters[:month]
        month_name = I18n.t('date.month_names')[@filters[:month]]
        t('.subtitle_monthly', month_name: month_name.capitalize, year: @filters[:year])
      else
        t('.subtitle_annual', year: @filters[:year])
      end
    end

    def metrics_grid
      div(class: 'grid grid-cols-2 lg:grid-cols-4 gap-3 mb-6') do
        metric_card(:per_day, format_currency(metrics[:per_day]))
        metric_card(:per_trip, format_currency(metrics[:per_trip]))
        metric_card(:per_hour, format_currency(metrics[:per_hour]), hint: t('.metrics.per_hour_hint'))
        metric_card(:margin, "#{format_percentage(metrics[:margin])}%", pp: true)
      end
    end

    def metric_card(key, value, hint: nil, pp: false)
      render Analysis::MetricCardComponent.new(
        label: t(".metrics.#{key}"),
        icon: METRIC_ICONS[key],
        value: value,
        hint: hint,
        change_pct: metrics[:change_pct][key],
        pp: pp
      )
    end

    def bar_chart_section
      div(class: 'mb-6') { render Analysis::BarChartComponent.new(months: @insights[:monthly_bars]) }
    end

    def breakdown_section
      div(class: 'grid grid-cols-1 lg:grid-cols-2 gap-4 mb-6') do
        div { render Analysis::CategoryBarsComponent.new(categories: @insights[:categories]) }
        div { render Analysis::PlatformDonutComponent.new(platforms: @insights[:platforms], total: platforms_total) }
      end
    end

    def insights_section
      return if @insights[:insights].empty?

      section(class: 'mb-6 space-y-3') do
        @insights[:insights].each { |insight| render Analysis::InsightCardComponent.new(insight: insight) }
      end
    end

    def metrics
      @insights[:metrics]
    end

    def platforms_total
      @insights[:platforms].sum { |row| row[:amount].to_f }
    end
  end
end
