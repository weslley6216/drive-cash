module History
  class IndexView < ApplicationComponent
    include CardStyles
    include TopbarStyles

    def initialize(feed:, year:, month:, query:, slice:, periods:)
      @feed = feed
      @year = year
      @month = month
      @query = query
      @slice = slice
      @periods = periods
    end

    def view_template
      render LayoutComponent.new(
        title:       t('history.index.title'),
        bottom_nav:  :history,
        sidebar_nav: :history
      ) do
        render ScreenComponent.new(frame: true, inline_header: true) do |screen|
          screen.with_header do
            static_header
            filter_toolbar
          end
          screen.with_content do
            feed_section
            render FabComponent.new(filters: filter_context, bottom_nav: true)
          end
        end
        turbo_frame_tag 'modal'
      end
    end

    private

    def static_header
      div(class: "#{PHONE_BAR} #{DESKTOP_BAR}") do
        div(class: 'flex items-start justify-between gap-3 lg:items-center lg:gap-6') do
          div(class: 'min-w-0') do
            h1(class: 'text-2xl font-bold text-slate-800 leading-tight truncate lg:leading-8 lg:text-slate-900 lg:tracking-tight') do
              t('history.index.title')
            end
            p(class: 'text-sm text-slate-500 mt-0.5 lg:hidden') { t('history.index.subtitle') }
            p(class: 'hidden lg:block text-sm text-slate-500 mt-0.5') do
              t('history.index.count_subtitle', count: @feed[:total_count], period: period_label)
            end
          end
          div(class: 'flex items-center gap-3 flex-shrink-0') do
            render FilterComponent.new(
              selected_year:  @year,
              selected_month: @month,
              periods:        @periods,
              variant:        :popover,
              action_path:    history_path
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

    def filter_toolbar
      div(class: 'px-5 sm:px-6 pb-3 space-y-3 lg:px-0 lg:pt-8 lg:pb-5 lg:space-y-5') do
        div(class: 'space-y-3 lg:space-y-0 lg:flex lg:items-center lg:gap-3') do
          div(class: 'lg:flex-1 lg:max-w-md') { render History::SearchBarComponent.new(query: @query, slice: @slice) }
          render History::FilterChipsComponent.new(slice: @slice, query: @query, year: @year, month: @month)
        end
        render History::PeriodSummaryComponent.new(summary: @feed[:summary]) unless no_result?
      end
    end

    def feed_section
      if @feed[:groups].empty?
        empty_state
      else
        turbo_frame_tag('history-feed', class: 'block') do
          div(class: 'space-y-4 lg:hidden', data: { controller: 'highlight', highlight_active_class: HIGHLIGHT_RING }) do
            @feed[:groups].each do |group|
              render History::DayGroupComponent.new(group: group, context: filter_context)
            end
          end
          div(class: 'hidden lg:block', data: { controller: 'highlight', highlight_active_class: History::TableComponent::HIGHLIGHT_OUTLINE }) do
            render History::TableComponent.new(groups: @feed[:groups], context: filter_context)
          end
          load_more_button
        end
      end
    end

    def load_more_button
      return unless @feed[:next_page]

      div(class: 'mt-4') { render History::LoadMoreComponent.new(path: load_more_path) }
    end

    def load_more_path
      history_path(**filter_context, page: @feed[:next_page])
    end

    def period_label
      return @year.to_s if @month.blank?

      "#{I18n.t('date.month_names')[@month]} #{@year}"
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

      preset = @slice.active_preset
      return t('empty_states.history.description_query', query: @query) if preset == 'all'

      filter_label = @slice.filtering? ? History::SliceTrail.new(@slice).sentence : t("history.index.filters.#{preset}")
      t('empty_states.history.description_query_filter', query: @query, filter: filter_label)
    end

    def no_result?
      filtering? && @feed[:groups].empty?
    end

    def filtering?
      @query.present? || @slice.active_preset != 'all'
    end

    def filter_context
      { year: @year, month: @month, q: @query }.compact.merge(@slice.to_params)
    end
  end
end
