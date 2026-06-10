class FilterComponent < ApplicationComponent
  def initialize(selected_year:, selected_month:, available_years: [], compact: false, popover: false, action_path: nil)
    @selected_year = selected_year
    @selected_month = selected_month
    @available_years = available_years
    @compact = compact
    @popover = popover
    @action_path = action_path
  end

  def view_template
    return popover_view if @popover

    @compact ? compact_view : full_view
  end

  private

  def popover_view
    div(
      class: 'relative',
      data: { controller: 'filter-popover', action: 'click@window->filter-popover#closeOnOutsideClick' }
    ) do
      button(
        type: 'button',
        class: 'w-9 h-9 rounded-full bg-white border border-slate-200 shadow-sm ' \
               'flex items-center justify-center text-slate-600 hover:bg-slate-50 ' \
               'focus:outline-none focus:ring-2 focus:ring-blue-500 cursor-pointer',
        title: t('.title'),
        data: { action: 'click->filter-popover#toggle' }
      ) do
        render PhlexIcons::Lucide::Funnel.new(class: 'w-[18px] h-[18px]')
      end

      div(
        class: 'hidden absolute right-0 mt-2 z-20 w-56 bg-white border border-slate-200 ' \
               'rounded-xl shadow-lg p-3',
        data: { filter_popover_target: 'panel' }
      ) do
        form(
          action: @action_path || root_path, method: 'get',
          class: 'flex flex-col gap-3',
          data: { controller: 'filter' }
        ) do
          popover_field(t('.year'),  :year,  action: 'change->filter#handleYearChange') { year_options }
          popover_field(t('.month'), :month, action: 'change->filter#submit') { month_options }
        end
      end
    end
  end

  def popover_field(label_text, name, action:)
    div(class: 'flex flex-col gap-1') do
      label(class: 'text-xs font-medium text-slate-500') { label_text }
      select(
        name: name, class: panel_select_classes,
        data: { filter_target: name, action: action }
      ) { yield }
    end
  end

  def panel_select_classes
    'w-full bg-white border border-slate-200 rounded-lg px-3 py-2 text-sm font-medium ' \
      'text-slate-700 focus:outline-none focus:ring-2 focus:ring-blue-500 cursor-pointer'
  end

  def compact_view
    form(
      action: @action_path || root_path, method: 'get',
      class: 'flex items-center gap-2',
      data: { controller: 'filter' }
    ) do
      select(
        name: 'year', class: pill_classes,
        data: { filter_target: 'year', action: 'change->filter#handleYearChange' }
      ) { year_options }
      select(
        name: 'month', class: pill_classes,
        data: { filter_target: 'month', action: 'change->filter#submit' }
      ) { month_options }
    end
  end

  def pill_classes
    'bg-white border border-slate-200 rounded-lg px-3 py-2 text-sm font-medium ' \
      'text-slate-700 hover:bg-slate-50 focus:outline-none focus:ring-2 focus:ring-blue-500 cursor-pointer'
  end

  def full_view
    current_params = { year: @selected_year, month: @selected_month }.compact
    target_url = helpers.url_for(controller: 'dashboard', action: 'index', **current_params)

    div(
      id: 'dashboard_filters',
      class: 'bg-white rounded-lg shadow-md p-4 mb-8 inline-block w-full',
      data: {
        controller: 'url-sync',
        url_sync_url_value: target_url
      }
    ) do
      form(
        action: root_path,
        method: 'get',
        data: {
          controller: 'filter',
          action: 'change->filter#submit'
        },
        class: 'flex items-center gap-4'
      ) do
        filter_header
        year_field
        month_field
      end
    end
  end

  def filter_header
    div(class: 'flex items-center gap-2 whitespace-nowrap') do
      render PhlexIcons::Lucide::Funnel.new(class: 'w-5 h-5 text-slate-600')
      span(class: 'text-sm font-medium text-slate-700') { t('.title') }
    end
  end

  def year_field
    div(class: 'flex items-center gap-2') do
      label(for: 'year_select', class: 'text-sm text-slate-600') { t('.year') }
      select(
        name: 'year',
        id: 'year_select',
        class: select_classes,
        data: {
          filter_target: 'year',
          action: 'change->filter#handleYearChange'
        }
      ) do
        year_options
      end
    end
  end

  def month_field
    div(class: 'flex items-center gap-2') do
      label(for: 'month_select', class: 'text-sm text-slate-600') { t('.month') }
      select(
        name: 'month',
        id: 'month_select',
        class: select_classes,
        data: { filter_target: 'month' }
      ) do
        month_options
      end
    end
  end

  def year_options
    @available_years.each do |year|
      option(value: year, selected: year.to_s == @selected_year.to_s) { year }
    end
  end

  def month_options
    option(value: '', selected: @selected_month.nil?) { t('.all_months') }

    (1..12).each do |month_index|
      label = I18n.t('date.abbr_month_names')[month_index].upcase
      option(value: month_index, selected: month_index.to_s == @selected_month.to_s) { label }
    end
  end

  def select_classes
    [
      'px-2 py-2 border border-slate-300 rounded-lg',
      'bg-white text-slate-800 font-medium',
      'focus:outline-none focus:ring-2 focus:ring-blue-500',
      'cursor-pointer hover:bg-slate-50 transition-colors'
    ].join(' ')
  end
end
