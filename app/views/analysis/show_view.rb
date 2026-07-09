module Analysis
  class ShowView < ApplicationView
    METRIC_ICONS = {
      per_day:  PhlexIcons::Lucide::Zap,
      per_trip: PhlexIcons::Lucide::Package,
      per_km:   PhlexIcons::Lucide::Route,
      margin:   PhlexIcons::Lucide::Gauge
    }.freeze

    def initialize(insights:, filters:)
      @insights = insights
      @filters = filters
    end

    def view_template
      render LayoutComponent.new(
        title:       t('.title'),
        bottom_nav:  :analysis,
        sidebar_nav: :analysis,
        app_shell:   true
      ) do
        turbo_frame_tag 'page', class: 'flex-1 flex flex-col min-h-0' do
          div(id: 'flash', class: 'flex-none') { render FlashComponent.new(flash: helpers.flash) }

          pinned_topbar
          loading_region
        end
        turbo_frame_tag 'modal'
      end
    end

    private

    def pinned_topbar
      div(class: 'flex-none px-4 sm:px-6 pt-4') { topbar }
    end

    def loading_region
      div(class: 'feed-loading-region flex-1 flex flex-col min-h-0') do
        div(class: 'feed-loading-overlay') do
          div(class: 'w-8 h-8 rounded-full border-4 border-slate-100 border-t-blue-600 animate-spin')
        end
        content_scroll_region
      end
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
          selected_year:   @filters[:year],
          selected_month:  @filters[:month],
          available_years: @filters[:available_years],
          variant:         :popover,
          action_path:     helpers.analysis_path
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
        metric_card(:per_km, per_km_value, hint: per_km_hint)
        metric_card(:margin, "#{format_percentage(metrics[:margin])}%")
      end
    end

    def per_km_value
      value = metrics[:per_km]
      return '—' if value.nil?

      format_currency(value)
    end

    def per_km_hint
      metrics[:per_km].nil? ? t('.metrics.per_km_empty') : t('.metrics.per_km_hint')
    end

    def metric_card(key, value, hint: nil, pp: false)
      render Analysis::MetricCardComponent.new(
        label:        t(".metrics.#{key}"),
        icon:         METRIC_ICONS[key],
        value:        value,
        hint:         hint,
        change_pct:   metrics[:change_pct][key],
        pp:           pp,
        period_label: period_label_for(pp)
      )
    end

    def period_label_for(_pp)
      period_context = @insights[:period_context]
      return nil unless period_context

      if period_context[:mode] == :monthly
        I18n.t('analysis.show_view.metrics.vs_period_monthly',
               month: period_context[:previous_month_name],
               year:  period_context[:previous_year])
      elsif period_context[:cutoff_month_name]
        I18n.t('analysis.show_view.metrics.vs_period_annual_ytd',
               month: period_context[:cutoff_month_name],
               year:  period_context[:previous_year])
      else
        I18n.t('analysis.show_view.metrics.vs_period_annual', year: period_context[:previous_year])
      end
    end

    def bar_chart_section
      div(class: 'mb-6') do
        render Analysis::BarChartComponent.new(
          bars:  @insights[:monthly_bars],
          month: @filters[:month],
          year:  @filters[:year]
        )
      end
    end

    def breakdown_section
      div(class: 'grid grid-cols-1 lg:grid-cols-2 gap-4 mb-6') do
        div { render Analysis::CategoryBarsComponent.new(categories: @insights[:categories], month: @filters[:month]) }
        div do
          render Analysis::PlatformDonutComponent.new(
            platforms: @insights[:platforms],
            total:     @insights[:platforms_total],
            month:     @filters[:month]
          )
        end
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
  end
end
