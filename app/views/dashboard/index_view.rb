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
      render FilterComponent.new(
        selected_year: @filters[:year],
        selected_month: @filters[:month],
        available_years: @filters[:available_years]
      )
    end

    def fab_button
      a(
        href: new_trip_path(context: { year: @filters[:year], month: @filters[:month] }),
        data_turbo_frame: 'modal',
        class: 'fixed bottom-6 right-6 z-40 flex items-center justify-center gap-2 bg-blue-600 text-white rounded-full w-14 h-14 sm:w-auto sm:h-auto sm:rounded-lg sm:px-5 sm:py-3 shadow-lg hover:shadow-xl hover:bg-blue-700 transition-all duration-200 transform hover:scale-105 active:scale-95'
      ) do
        render PhlexIcons::Lucide::Plus.new(class: 'w-6 h-6 sm:w-5 sm:h-5')

        span(class: 'hidden sm:inline font-medium') { t('.new_earning') }
      end
    end

    def modal_container
      turbo_frame_tag 'modal'
    end
  end
end
