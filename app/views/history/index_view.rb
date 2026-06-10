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
      render LayoutComponent.new(
        title: t('history.index.title'),
        bottom_nav: :history,
        sidebar_nav: :history,
        app_shell: true
      ) do
        turbo_frame_tag 'page' do
          div(id: 'flash', class: 'flex-none') { render FlashComponent.new(flash: helpers.flash) }

          pinned_header
          feed_scroll_region

          render FabComponent.new(filters: filter_context, bottom_nav: true)
        end
        turbo_frame_tag 'modal'
      end
    end

    private

    def pinned_header
      div(class: 'flex-none px-4 sm:px-6 pt-4 space-y-4') do
        header_section
        render History::PeriodSummaryComponent.new(summary: @feed[:summary])
        div do
          render History::SearchBarComponent.new(query: @query, filter: @filter)
          div(class: 'mt-3') do
            render History::FilterChipsComponent.new(current_filter: @filter, query: @query, year: @year, month: @month)
          end
        end
      end
    end

    def feed_scroll_region
      div(class: 'flex-1 min-h-0 overflow-y-auto px-4 sm:px-6 pt-2 pb-24 lg:pb-6') do
        feed_section
      end
    end

    def header_section
      div(class: 'flex flex-col gap-1 lg:flex-row lg:items-end lg:justify-between') do
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
