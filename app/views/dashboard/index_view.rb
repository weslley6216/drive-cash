module Dashboard
  class IndexView < ApplicationComponent
    def initialize(totals:, filters: {})
      @totals = totals
      @filters = filters
    end

    def view_template
      render LayoutComponent.new(title: t('.title')) do
        div(id: 'flash') { render FlashComponent.new(flash: helpers.flash) }

        header
        filters_section
        div(id: 'stats_grid') do
          render StatsGridComponent.new(totals: @totals)
        end
        fab_button
        modal_container
      end
    end

    private

    def header
      div(class: 'mb-8') do
        h1(class: 'text-4xl font-bold text-slate-800 mb-2') { t('.title') }
        p(class: 'text-slate-600') { t('.subtitle') }
      end
    end

    def filters_section
      div(id: 'dashboard_filters') do
        render FilterComponent.new(
          selected_year: @filters[:year],
          selected_month: @filters[:month],
          available_years: @filters[:available_years]
        )
      end
    end

    def fab_button
      render FabComponent.new(filters: { year: @filters[:year], month: @filters[:month] })
    end

    def modal_container
      turbo_frame_tag 'modal'
    end
  end
end
