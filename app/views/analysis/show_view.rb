module Analysis
  class ShowView < ApplicationView
    include CardStyles
    include TopbarStyles

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
      div(class: "flex-none px-5 pt-2 pb-3 sm:px-6 #{DESKTOP_BAR}") { topbar }
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
      div(class: 'flex-1 min-h-0 overflow-y-auto px-5 sm:px-6 pb-24 lg:px-0 lg:pt-8 lg:pb-8 space-y-4 lg:space-y-6') do
        if empty?
          empty_state
        else
          metrics_grid
          bar_chart_section
          breakdown_section
          insights_section
        end
      end
    end

    def empty?
      metrics[:earnings].to_f.zero? && metrics[:expenses].to_f.zero?
    end

    def empty_state
      div(class: 'space-y-4') do
        dimmed_chart_frame
        div(class: CARD) do
          render EmptyStateComponent.new(
            icon:        PhlexIcons::Lucide::ChartColumn,
            title:       t('empty_states.analysis.title', period: period_label),
            description: t('empty_states.analysis.description'),
            cta_label:   t('empty_states.analysis.cta'),
            cta_path:    helpers.new_record_path,
            cta_icon:    PhlexIcons::Lucide::Plus,
            cta_data:    { turbo_frame: 'modal' }
          )
        end
      end
    end

    def dimmed_chart_frame
      div(class: "#{CARD} p-4") do
        p(class: 'text-sm font-semibold text-slate-700 mb-3') { t('.empty_chart_title') }
        div(class: 'flex items-end justify-between gap-1 h-[90px]') do
          14.times do
            div(class: 'flex-1 flex justify-center') do
              div(class: 'w-1.5 h-[3px] rounded-full bg-slate-200')
            end
          end
        end
      end
    end

    def period_label
      return @filters[:year].to_s unless @filters[:month]

      I18n.t('date.month_names')[@filters[:month]]
    end

    def topbar
      div(class: 'flex items-start justify-between gap-3 lg:items-center lg:gap-6') do
        div(class: 'min-w-0') do
          h1(class: 'text-2xl font-bold text-slate-800 leading-tight lg:leading-8 lg:text-slate-900 lg:tracking-tight') { t('.title') }
          p(class: 'text-sm text-slate-500 mt-0.5') { subtitle }
        end

        div(class: 'flex items-center gap-3 flex-shrink-0') do
          render FilterComponent.new(
            selected_year:   @filters[:year],
            selected_month:  @filters[:month],
            available_years: @filters[:available_years],
            variant:         :popover,
            action_path:     helpers.analysis_path
          )
          export_link
        end
      end
    end

    def export_link
      a(href: helpers.exports_path, class: 'hidden lg:flex items-center gap-2 bg-white border border-slate-200 rounded-lg px-3 py-2 ' \
                                           'text-sm font-medium text-slate-700 hover:bg-slate-50') do
        render PhlexIcons::Lucide::Download.new(class: 'w-3.5 h-3.5 text-slate-500')
        plain t('.export')
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
      div(class: 'space-y-3 lg:space-y-0 lg:grid lg:grid-cols-[1.4fr_1fr_1fr_1fr] lg:gap-4') do
        metric_card(:per_km, per_km_value, label_key: :per_km_hero, variant: :hero)
        div(class: 'grid grid-cols-2 gap-3 lg:contents') do
          metric_card(:per_day, format_currency(metrics[:per_day]))
          metric_card(:per_trip, format_currency(metrics[:per_trip]))
          metric_card(:margin, format_currency(metrics[:margin]), class_name: 'col-span-2 lg:col-span-1')
        end
      end
    end

    def per_km_value
      value = metrics[:per_km]
      return '—' if value.nil?

      format_currency(value)
    end

    def metric_card(key, value, label_key: key, variant: :compact, class_name: nil)
      render Analysis::MetricCardComponent.new(
        label:      t(".metrics.#{label_key}"),
        icon:       METRIC_ICONS[key],
        value:      value,
        series:     metrics[:series][key],
        variant:    variant,
        class_name: class_name
      )
    end

    def bar_chart_section
      render Analysis::BarChartComponent.new(
        bars:  @insights[:monthly_bars],
        month: @filters[:month],
        year:  @filters[:year]
      )
    end

    def breakdown_section
      div(class: 'grid grid-cols-1 lg:grid-cols-12 gap-4 lg:gap-5') do
        div(class: 'lg:col-span-7') { render Analysis::CategoryBarsComponent.new(categories: @insights[:categories], month: @filters[:month]) }
        div(id: 'platform_breakdown', class: 'hidden lg:block lg:col-span-5') do
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

      section(class: 'space-y-3') do
        @insights[:insights].each { |insight| render Analysis::InsightCardComponent.new(insight: insight) }
      end
    end

    def metrics
      @insights[:metrics]
    end
  end
end
