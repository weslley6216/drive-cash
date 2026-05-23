module Dashboard
  class IndexView < ApplicationComponent
    def initialize(totals:, filters: {}, recent_activity: [], categories: [])
      @totals = totals
      @filters = filters
      @recent_activity = recent_activity
      @categories = categories
    end

    def view_template
      render LayoutComponent.new(title: t('.title'), bottom_nav: :home) do
        div(id: 'flash') { render FlashComponent.new(flash: helpers.flash) }

        greeting_header
        filters_section
        hero_section
        caju_section
        stats_grid
        recent_activity_section
        category_breakdown_section
        fab_button
        modal_container
      end
    end

    private

    def greeting_header
      div(class: 'mb-4') do
        h1(class: 'text-2xl font-bold text-slate-800') { t('.greeting') }
        p(class: 'text-sm text-slate-500') { t('.subtitle') }
      end
    end

    def filters_section
      render FilterComponent.new(
        selected_year: @filters[:year],
        selected_month: @filters[:month],
        available_years: @filters[:available_years]
      )
    end

    def hero_section
      render HeroProfitCardComponent.new(
        profit: @totals[:profit],
        change_percent: @totals[:change_percent],
        profit_per_day: @totals[:profit_per_day],
        days_count: @totals[:days],
        monthly_series: @totals[:monthly_profit_series],
        year: @filters[:year],
        month: @filters[:month]
      )
    end

    def caju_section
      div(class: 'mt-3') { render CajuQuickAccessComponent.new }
    end

    def stats_grid
      div(class: 'mt-6') do
        render StatsGridComponent.new(
          totals: @totals,
          month: @filters[:month],
          year: @filters[:year]
        )
      end
    end

    def recent_activity_section
      render RecentActivityComponent.new(rows: @recent_activity)
    end

    def category_breakdown_section
      render CategoryBreakdownComponent.new(categories: @categories)
    end

    def fab_button
      render FabComponent.new(
        filters: { year: @filters[:year], month: @filters[:month] },
        bottom_nav: true
      )
    end

    def modal_container
      turbo_frame_tag 'modal'
    end
  end
end
