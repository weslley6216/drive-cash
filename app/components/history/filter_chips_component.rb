module History
  class FilterChipsComponent < ApplicationComponent
    def initialize(current_filter:, query:, year: nil, month: nil)
      @current_filter = current_filter
      @query = query
      @year = year
      @month = month
    end

    def view_template
      div(class: 'flex gap-2 overflow-x-auto -mx-1 px-1 lg:flex-wrap lg:overflow-visible lg:mx-0 lg:px-0') do
        visible_filters.each { |filter| chip(filter) }
      end
    end

    private

    def visible_filters
      History::FeedService::FILTERS.filter_map do |filter, config|
        filter if config.chip == :always || filter == @current_filter
      end
    end

    def chip(filter)
      active = filter == @current_filter
      link_to(
        history_path(filter: filter, q: @query.presence, year: @year, month: @month),
        class: class_names(base_classes, active ? active_classes : inactive_classes)
      ) { t(History::FeedService::FILTERS.fetch(filter).label_key) }
    end

    def base_classes
      'whitespace-nowrap rounded-full lg:rounded-lg px-3 py-1.5 text-xs font-medium transition-colors'
    end

    def active_classes
      'bg-slate-800 text-white'
    end

    def inactive_classes
      'bg-white border border-slate-200 text-slate-600 hover:bg-slate-50'
    end
  end
end
