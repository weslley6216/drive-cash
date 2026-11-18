module History
  class FilterChipsComponent < ApplicationComponent
    def initialize(slice:, query:, year: nil, month: nil)
      @slice = slice
      @query = query
      @year = year
      @month = month
    end

    def view_template
      div(class: 'flex gap-2 overflow-x-auto -mx-1 px-1 lg:flex-wrap lg:overflow-visible lg:mx-0 lg:px-0',
          data:  { controller: 'chip-strip' }) do
        Slice::PRESETS.each_key { |key| chip(key) }
      end
    end

    private

    def chip(key)
      active = key == @slice.active_preset
      link_to(
        history_path(**Slice.preset(key).to_params, q: @query.presence, year: @year, month: @month),
        class: class_names(base_classes, active ? active_classes : inactive_classes),
        data:  active ? { chip_strip_target: 'active' } : {}
      ) { t("history.index.filters.#{key}") }
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
