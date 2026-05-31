module History
  class IndexView < ApplicationComponent
    def initialize(feed:, year:, month:, query:, filter:, available_years:)
      @feed            = feed
      @year            = year
      @month           = month
      @query           = query
      @filter          = filter
      @available_years = available_years
    end

    def view_template
      render LayoutComponent.new(title: t('history.index.title'), bottom_nav: :history, sidebar_nav: :history) do
        div(id: 'flash') { render FlashComponent.new(flash: helpers.flash) }

        header_section
        render History::PeriodSummaryComponent.new(summary: @feed[:summary])
        sticky_filters
        feed_section
        render FabComponent.new(filters: filter_context, bottom_nav: true)
        turbo_frame_tag 'modal'
      end
    end

    private

    def header_section
      div(class: 'mb-4 flex flex-col gap-1 lg:flex-row lg:items-end lg:justify-between') do
        div do
          h1(class: 'text-2xl lg:text-3xl font-bold text-slate-900 tracking-tight') { t('history.index.title') }
          p(class: 'text-sm text-slate-500') { t('history.index.subtitle') }
        end
        render FilterComponent.new(
          selected_year: @year,
          selected_month: @month,
          available_years: @available_years,
          compact: true,
          action_path: history_path
        )
      end
    end

    def sticky_filters
      div(class: 'sticky top-0 z-10 -mx-4 px-4 sm:-mx-6 sm:px-6 pt-2 pb-3 mb-4 bg-white/90 backdrop-blur-sm') do
        render History::SearchBarComponent.new(query: @query, filter: @filter)
        render History::FilterChipsComponent.new(current_filter: @filter, query: @query)
      end
    end

    def feed_section
      if @feed[:groups].empty?
        empty_state
      else
        div(class: 'space-y-5') do
          @feed[:groups].each do |group|
            render History::DayGroupComponent.new(group: group, context: filter_context)
          end
        end
      end
    end

    def empty_state
      p(class: 'text-sm text-slate-500 bg-white border border-slate-200 rounded-xl px-4 py-8 text-center') do
        t('history.index.empty')
      end
    end

    def filter_context
      { year: @year, month: @month, q: @query, filter: @filter }.compact
    end
  end
end
