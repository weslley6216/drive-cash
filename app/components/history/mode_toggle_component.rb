module History
  class ModeToggleComponent < ApplicationComponent
    TAP_TARGET = "relative after:absolute after:inset-x-0 after:-inset-y-3 after:content-['']".freeze

    def initialize(slice:, query:)
      @slice = slice
      @query = query
    end

    def view_template
      div(class: 'flex bg-slate-100 rounded-lg p-0.5 text-[11px] font-semibold') do
        item('month', inactive: @slice.twelve_months?) { t('history.index.mode.month') }
        item('twelve_months', inactive: !@slice.twelve_months?) { t('history.index.mode.twelve_months') }
      end
    end

    private

    def item(mode, inactive:, &content)
      if inactive
        link_to(path_for(mode), class: class_names(item_classes(false), TAP_TARGET), data: { mode_toggle: mode }, &content)
      else
        span(class: item_classes(true), data: { mode_toggle: mode }, &content)
      end
    end

    def item_classes(active)
      base = 'px-2.5 py-1 rounded-md'
      active ? "#{base} bg-white text-slate-900 shadow-sm" : "#{base} text-slate-500"
    end

    def path_for(mode)
      return history_path(**@slice.with_twelve_months.to_params, q: @query.presence) if mode == 'twelve_months'

      history_path(year: Date.current.year, month: Date.current.month, **@slice.without_range.to_params, q: @query.presence)
    end
  end
end
