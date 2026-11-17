module History
  class LoadMoreComponent < ApplicationComponent
    def initialize(path:)
      @path = path
    end

    def view_template
      link_to(t('history.index.load_more'), @path,
              data:  { turbo_frame: 'history-feed', turbo_action: 'advance' },
              class: 'block w-full py-3 text-sm font-medium text-blue-600 border border-slate-200 bg-white rounded-xl text-center')
    end
  end
end
