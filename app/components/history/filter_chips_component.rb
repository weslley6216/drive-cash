module History
  class FilterChipsComponent < ApplicationComponent
    def initialize(slice:, query:, year: nil, month: nil)
      @slice = slice
      @query = query
      @year = year
      @month = month
    end

    def view_template
      div(class: 'flex items-center gap-2 overflow-x-auto -mx-1 px-1 py-2 -my-2 lg:flex-wrap lg:overflow-visible lg:mx-0 lg:px-0',
          data:  { controller: 'chip-strip' }) do
        filters_button
        @slice.filtering? ? pills : Slice::PRESETS.each_key { |key| chip(key) }
        clear_link if @slice.filtering?
        mode_toggle
      end
    end

    private

    def mode_toggle
      return unless @slice.single_series? && (@month.present? || @slice.twelve_months?)

      div(class: 'hidden lg:block ml-auto') { render ModeToggleComponent.new(slice: @slice, query: @query) }
    end

    def filters_button
      button(
        type:  'button',
        class: class_names(filters_button_base_classes, @slice.filtering? ? active_classes : 'bg-white border border-slate-200 text-slate-700'),
        data:  { action: 'history-filter-panel#open' }
      ) do
        render PhlexIcons::Lucide::SlidersHorizontal.new(class: 'w-[13px] h-[13px]')
        plain(@slice.filtering? ? t('history.index.filters.button_count', count: @slice.pill_count) : t('history.index.filters.button'))
      end
    end

    def pills
      History::SliceTrail.new(@slice).pills.each do |pill|
        render PhlexIcons::Lucide::ChevronRight.new(class: 'w-3 h-3 text-slate-400 flex-shrink-0') if pill.nested
        pill_chip(pill)
      end
    end

    def pill_chip(pill)
      span(data: { slice_pill: pill.level }, class: pill_classes) do
        button(type: 'button', class: 'py-[14px] -my-[14px]', data: { action: 'history-filter-panel#open', history_filter_panel_level_param: pill.level }) { plain pill.label }
        link_to(history_path(**pill.remove_params, q: @query.presence, year: @year, month: @month),
                class: 'flex items-center py-4 -my-4 pl-2.5 -ml-2.5 pr-3.5 -mr-3.5',
                aria:  { label: t('history.index.trail.remove', label: pill.label) }) do
          render PhlexIcons::Lucide::X.new(class: 'w-3 h-3', 'stroke-width': '2.6')
        end
      end
    end

    def clear_link
      link_to(history_path(q: @query.presence, year: @year, month: @month),
              class: 'hidden lg:inline text-xs font-semibold text-slate-500 hover:text-slate-800 ml-1') { t('history.index.filters.clear') }
    end

    def chip(key)
      active = key == @slice.active_preset
      link_to(
        history_path(**Slice.preset(key).to_params, q: @query.presence, year: @year, month: @month),
        class: class_names(base_classes, active ? active_classes : inactive_classes),
        data:  active ? { chip_strip_target: 'active' } : {}
      ) { t("history.index.filters.#{key}") }
    end

    def filters_button_base_classes
      'relative flex items-center gap-1.5 px-3 py-1.5 rounded-full lg:rounded-lg text-xs font-semibold whitespace-nowrap flex-shrink-0 ' \
        "after:absolute after:inset-x-0 after:-inset-y-2 after:content-['']"
    end

    def pill_classes
      'flex items-center gap-1 pl-2.5 pr-1.5 py-1.5 rounded-full lg:rounded-lg text-xs font-semibold whitespace-nowrap flex-shrink-0 bg-blue-50 border border-blue-200 text-blue-700'
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
