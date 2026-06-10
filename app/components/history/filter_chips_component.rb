module History
  class FilterChipsComponent < ApplicationComponent
    FILTERS = History::FeedService::FILTERS

    def initialize(current_filter:, query:, year: nil, month: nil)
      @current_filter = current_filter
      @query = query
      @year = year
      @month = month
    end

    def view_template
      div(class: 'flex items-center gap-2 mt-2 overflow-x-auto pb-1') do
        FILTERS.each { |filter| chip(filter) }
      end
    end

    private

    def chip(filter)
      active = filter == @current_filter
      link_to(
        history_path(filter: filter, q: @query.presence, year: @year, month: @month),
        class: class_names(base_classes, active ? active_classes : inactive_classes)
      ) { t("history.index.filters.#{filter}") }
    end

    def base_classes
      'whitespace-nowrap rounded-full px-3 py-1.5 text-sm font-medium transition-colors'
    end

    def active_classes
      'bg-slate-800 text-white'
    end

    def inactive_classes
      'bg-white border border-slate-200 text-slate-600 hover:bg-slate-50'
    end
  end
end
