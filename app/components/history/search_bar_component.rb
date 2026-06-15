module History
  class SearchBarComponent < ApplicationComponent
    def initialize(query:, filter:)
      @query = query
      @filter = filter
    end

    def view_template
      form(
        action: history_path,
        method: 'get',
        class:  'relative',
        data:   { controller: 'history-search' }
      ) do
        input(type: 'hidden', name: 'filter', value: @filter)

        div(class: 'relative') do
          render PhlexIcons::Lucide::Search.new(
            class: 'w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none'
          )
          input(
            type:         'search',
            name:         'q',
            value:        @query,
            placeholder:  t('history.index.search_placeholder'),
            autocomplete: 'off',
            class:        input_classes,
            data:         { action: 'input->history-search#debounce' }
          )
          clear_button if @query.present?
        end
      end
    end

    private

    def clear_button
      link_to(
        history_path(filter: @filter),
        class:      'cursor-pointer absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600',
        aria_label: t('history.index.search_clear'),
        title:      t('history.index.search_clear')
      ) do
        render PhlexIcons::Lucide::X.new(class: 'w-4 h-4')
      end
    end

    def input_classes
      'w-full rounded-xl border border-slate-200 bg-white pl-9 pr-8 py-2.5 text-sm ' \
        '[&::-webkit-search-cancel-button]:hidden ' \
        'text-slate-800 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500'
    end
  end
end
