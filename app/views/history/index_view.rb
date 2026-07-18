module History
  class IndexView < ApplicationComponent
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
        turbo_frame_tag 'page', class: 'flex-1 flex flex-col min-h-0' do
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
      div(class: 'flex-none px-4 sm:px-6 pt-4 space-y-4') do
        header_section
        render History::PeriodSummaryComponent.new(summary: @feed[:summary])
      end
    end

    def filterable_region
      div(class: 'feed-loading-region flex-1 flex flex-col min-h-0') do
        div(class: 'feed-loading-overlay') do
          div(class: 'w-8 h-8 rounded-full border-4 border-slate-100 border-t-blue-600 animate-spin')
        end
        div(class: 'flex-none px-4 sm:px-6 pt-4 pb-2 space-y-3') do
          render History::SearchBarComponent.new(query: @query, filter: @filter)
          render History::FilterChipsComponent.new(current_filter: @filter, query: @query, year: @year, month: @month)
        end
        div(class: 'flex-1 min-h-0 overflow-y-auto px-4 sm:px-6 pt-2 pb-24 lg:pb-6') do
          feed_section
        end
      end
    end

    def header_section
      div(class: 'flex flex-col gap-1 lg:flex-row lg:items-end lg:justify-between') do
        div do
          h1(class: 'text-2xl lg:text-3xl font-bold text-slate-900 tracking-tight') { t('history.index.title') }
          p(class: 'text-sm text-slate-500') { t('history.index.subtitle') }
        end
        render FilterComponent.new(
          selected_year:   @year,
          selected_month:  @month,
          available_years: @available_years,
          variant:         :compact,
          action_path:     history_path
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
      if filtering?
        render EmptyStateComponent.new(
          icon:        PhlexIcons::Lucide::Search,
          title:       t('empty_states.history.title'),
          description: t('empty_states.history.description'),
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
          cta_data:    { turbo_frame: 'modal' }
        )
      end
    end

    def filtering?
      @query.present? || (@filter.present? && @filter != 'all')
    end

    def filter_context
      { year: @year, month: @month, q: @query, filter: @filter }.compact
    end
  end
end
