module Dashboard
  class IndexView < ApplicationComponent
    def initialize(totals:, filters: {}, recent_activity: [], categories: [], today: nil)
      @totals = totals
      @filters = filters
      @recent_activity = recent_activity
      @categories = categories
      @today = today
    end

    def view_template
      render LayoutComponent.new(title: t('.title'), bottom_nav: :home, sidebar_nav: :home) do
        div(id: 'flash') { render FlashComponent.new(flash: helpers.flash) }

        topbar_section
        primary_grid
        stats_grid_section
        secondary_grid

        render FabComponent.new(filters: { year: @filters[:year], month: @filters[:month] }, bottom_nav: true)
        turbo_frame_tag 'modal'
      end
    end

    private

    def topbar_section
      div(class: 'mb-6 flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between') do
        div do
          h1(class: 'text-2xl lg:text-3xl font-bold text-slate-900 tracking-tight') { t('.greeting') }
          p(class: 'text-sm text-slate-500 mt-0.5') { t('.subtitle_period', year: @filters[:year]) }
        end

        div(class: 'flex items-center gap-2 flex-wrap') do
          render FilterComponent.new(
            selected_year: @filters[:year],
            selected_month: @filters[:month],
            available_years: @filters[:available_years],
            compact: true
          )
          link_to(new_earning_path,
                  data: { turbo_frame: 'modal' },
                  class: new_record_button_classes) do
            render PhlexIcons::Lucide::Plus.new(class: 'w-4 h-4')
            plain t('.new_record')
          end
        end
      end
    end

    def new_record_button_classes
      'hidden lg:inline-flex items-center gap-2 bg-blue-600 hover:bg-blue-700 ' \
      'text-white rounded-lg px-4 py-2 text-sm font-semibold'
    end

    def primary_grid
      div(class: 'grid grid-cols-1 lg:grid-cols-12 gap-4 mb-6') do
        div(class: 'lg:col-span-8') do
          monthly_view = @filters[:month].present?
          render HeroProfitCardComponent.new(
            profit: @totals[:profit],
            change_percent: @totals[:change_percent],
            profit_per_day: @totals[:profit_per_day],
            days_count: @totals[:days],
            monthly_series: monthly_view ? @totals[:daily_profit_series] : @totals[:monthly_profit_series],
            year: @filters[:year],
            month: @filters[:month],
            daily_mode: monthly_view
          )
        end

        div(class: 'lg:col-span-4 flex flex-col gap-4') do
          render CajuQuickAccessComponent.new
          render TodayCardComponent.new(**@today) if @today
        end
      end
    end

    def stats_grid_section
      render StatsGridComponent.new(
        totals: @totals,
        month: @filters[:month],
        year: @filters[:year]
      )
    end

    def secondary_grid
      div(class: 'grid grid-cols-1 lg:grid-cols-12 gap-4 mb-6') do
        div(class: 'lg:col-span-7') { render RecentActivityComponent.new(rows: @recent_activity) }
        div(class: 'lg:col-span-5') { render CategoryBreakdownComponent.new(categories: @categories) }
      end
    end
  end
end
