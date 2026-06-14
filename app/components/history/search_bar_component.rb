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
        end
      end
    end

    private

    def input_classes
      'w-full rounded-xl border border-slate-200 bg-white pl-9 pr-3 py-2.5 text-sm ' \
        'text-slate-800 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500'
    end
  end
end
