module History
  class IndexView < ApplicationComponent
    include CardStyles
    include TopbarStyles

    def initialize(feed:, year:, month:, query:, filter:, available_years:)
      @feed = feed
      @year = year
      @month = month
      @query = query
      @filter = filter
      @available_years = available_years
    end

    def view_template
      render LayoutComponent.new(
        title:       t('history.index.title'),
        bottom_nav:  :history,
        sidebar_nav: :history,
        app_shell:   true
      ) do
        turbo_frame_tag 'page', class: 'flex-1 flex flex-col min-h-0 safe-top sm:pt-0' do
          div(id: 'flash', class: 'flex-none') { render FlashComponent.new(flash: helpers.flash) }

          static_header
          filterable_region

          render FabComponent.new(filters: filter_context, bottom_nav: true)
        end
        turbo_frame_tag 'modal'
      end
    end

    private

    def static_header
      div(class: "flex-none px-5 pt-2 pb-3 sm:px-6 #{DESKTOP_BAR}") do
        div(class: 'flex items-start justify-between gap-3 lg:items-center lg:gap-6') do
          div(class: 'min-w-0') do
            h1(class: 'text-2xl font-bold text-slate-800 leading-tight truncate lg:leading-8 lg:text-slate-900 lg:tracking-tight') do
              t('history.index.title')
            end
            p(class: 'text-sm text-slate-500 mt-0.5') { t('history.index.subtitle') }
          end
          div(class: 'flex items-center gap-3 flex-shrink-0') do
            render FilterComponent.new(
              selected_year:   @year,
              selected_month:  @month,
              available_years: @available_years,
              variant:         :popover,
              action_path:     history_path
            )
            new_record_link
          end
        end
      end
    end

    def new_record_link
      link_to(helpers.new_record_path,
              data:  { turbo_frame: '_top' },
              class: 'hidden lg:flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg px-4 py-2 text-sm font-semibold') do
        render PhlexIcons::Lucide::Plus.new(class: 'w-4 h-4', 'stroke-width': '2.4')
        plain t('history.index.new_record')
      end
    end

    def filterable_region
      div(class: 'feed-loading-region flex-1 flex flex-col min-h-0') do
        div(class: 'feed-loading-overlay') do
          div(class: 'w-8 h-8 rounded-full border-4 border-slate-100 border-t-blue-600 animate-spin')
        end
        div(class: 'flex-none px-5 sm:px-6 pb-3 space-y-3 lg:px-0 lg:pt-8 lg:pb-5 lg:space-y-5') do
          div(class: 'space-y-3 lg:space-y-0 lg:flex lg:items-center lg:gap-3') do
            div(class: 'lg:flex-1 lg:max-w-md') { render History::SearchBarComponent.new(query: @query, filter: @filter) }
            render History::FilterChipsComponent.new(current_filter: @filter, query: @query, year: @year, month: @month)
          end
          render History::PeriodSummaryComponent.new(summary: @feed[:summary]) unless no_result?
        end
        div(class: 'flex-1 min-h-0 overflow-y-auto px-5 sm:px-6 pb-24 lg:px-0 lg:pb-8') do
          feed_section
        end
      end
    end

    def feed_section
      if @feed[:groups].empty?
        empty_state
      else
        div(class: 'space-y-4 lg:hidden') do
          @feed[:groups].each do |group|
            render History::DayGroupComponent.new(group: group, context: filter_context)
          end
        end
        div(class: 'hidden lg:block') { render History::TableComponent.new(groups: @feed[:groups], context: filter_context) }
      end
    end

    def empty_state
      div(class: CARD) do
        if filtering?
          render EmptyStateComponent.new(
            icon:        PhlexIcons::Lucide::Search,
            title:       t('empty_states.history.title'),
            description: no_result_description,
            cta_label:   t('empty_states.history.cta'),
            cta_path:    history_path(year: @year, month: @month),
            cta_icon:    PhlexIcons::Lucide::X
          )
        else
          render EmptyStateComponent.new(
            icon:        PhlexIcons::Lucide::Receipt,
            title:       t('empty_states.history.blank.title'),
            description: t('empty_states.history.blank.description'),
            cta_label:   t('empty_states.history.blank.cta'),
            cta_path:    helpers.new_record_path,
            cta_icon:    PhlexIcons::Lucide::Plus,
            cta_data:    { turbo_frame: '_top' }
          )
        end
      end
    end

    def no_result_description
      return t('empty_states.history.description') if @query.blank?
      return t('empty_states.history.description_query', query: @query) if @filter == 'all'

      t('empty_states.history.description_query_filter', query: @query, filter: t("history.index.filters.#{@filter}"))
    end

    def no_result?
      filtering? && @feed[:groups].empty?
    end

    def filtering?
      @query.present? || (@filter.present? && @filter != 'all')
    end

    def filter_context
      { year: @year, month: @month, q: @query, filter: @filter }.compact
    end
  end
end
