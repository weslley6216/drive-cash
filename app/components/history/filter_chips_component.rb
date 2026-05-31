module History
  class FilterChipsComponent < ApplicationComponent
    FILTERS = %w[all earnings expenses unpaid].freeze

    def initialize(current_filter:, query:)
      @current_filter = current_filter
      @query = query
    end

    def view_template
      div(class: 'flex items-center gap-2 mb-4 overflow-x-auto pb-1') do
        FILTERS.each { |filter| chip(filter) }
      end
    end

    private

    def chip(filter)
      active = filter == @current_filter
      link_to(
        history_path(filter: filter, q: @query.presence),
        class: class_names(base_classes, active ? active_classes : inactive_classes),
        data: { turbo_frame: '_top' }
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
