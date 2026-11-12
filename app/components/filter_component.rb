class FilterComponent < ApplicationComponent
  PILL = 'appearance-none bg-white border border-slate-200 rounded-lg py-2 text-sm font-medium text-slate-700 ' \
         'hover:bg-slate-50 focus:outline-none focus:ring-2 focus:ring-blue-500 cursor-pointer'.freeze
  CHIP = 'px-3 py-1.5 rounded-full text-sm whitespace-nowrap'.freeze
  CHIP_ACTIVE = 'bg-slate-800 text-white font-medium'.freeze
  CHIP_IDLE = 'bg-white border border-slate-200 text-slate-600'.freeze
  MONTH_LINK = 'px-1 py-1.5 rounded-lg text-xs text-center'.freeze

  def initialize(selected_year:, selected_month:, available_years: [], variant: :compact, action_path: nil)
    @selected_year = selected_year
    @selected_month = selected_month
    @available_years = available_years
    @variant = variant
    @action_path = action_path
  end

  def view_template
    send("#{@variant}_view")
  end

  private

  def compact_view
    pills_form
  end

  def chips_view
    div(class: 'flex items-center gap-2 -mx-1 px-1 -my-[5px] overflow-x-auto [scrollbar-width:none] lg:hidden') do
      year_chip_form
      month_chips
    end
    div(class: 'hidden lg:block') { pills_form }
  end

  def popover_view
    div(class: 'lg:hidden') { popover }
    div(class: 'hidden lg:block') { pills_form }
  end

  def pills_form
    form(action: target_path, method: 'get', class: 'flex items-center gap-3', data: { controller: 'filter' }) do
      pill(icon: PhlexIcons::Lucide::Calendar) do
        select(name: 'year', class: "#{PILL} pl-8 pr-8", data: { filter_target: 'year', action: 'change->filter#handleYearChange' }) do
          year_options
        end
      end
      pill do
        select(name: 'month', class: "#{PILL} pl-3 pr-8", data: { filter_target: 'month', action: 'change->filter#submit' }) do
          month_options
        end
      end
    end
  end

  def pill(icon: nil, &)
    div(class: 'relative flex items-center') do
      render icon.new(class: 'absolute left-3 w-3.5 h-3.5 text-slate-500 pointer-events-none') if icon
      yield
      render PhlexIcons::Lucide::ChevronDown.new(class: 'absolute right-3 w-3.5 h-3.5 text-slate-400 pointer-events-none')
    end
  end

  def year_chip_form
    form(action: target_path, method: 'get', class: 'flex-shrink-0', data: { controller: 'filter' }) do
      div(class: 'relative flex items-center') do
        render PhlexIcons::Lucide::Funnel.new(class: 'absolute left-3 w-3.5 h-3.5 text-slate-700 pointer-events-none')
        select(
          name:  'year',
          class: 'appearance-none bg-white border border-slate-200 rounded-full pl-8 pr-8 py-1.5 text-sm ' \
                 'font-medium text-slate-700 shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 cursor-pointer',
          data:  { filter_target: 'year', action: 'change->filter#submit' }
        ) { year_options }
        render PhlexIcons::Lucide::ChevronDown.new(class: 'absolute right-3 w-3.5 h-3.5 text-slate-700 pointer-events-none')
      end
    end
  end

  def month_chips
    chip_link(t('.all_chip'), nil)
    selectable_months.each { |month| chip_link(I18n.t('date.abbr_month_names')[month].capitalize, month) }
  end

  def chip_link(label, month)
    active = month.to_s == @selected_month.to_s
    a(href: period_path(month), class: 'flex-shrink-0 flex items-center h-11') do
      span(class: "#{CHIP} #{active ? CHIP_ACTIVE : CHIP_IDLE}") { label }
    end
  end

  def popover
    div(class: 'relative', data: { controller: 'filter-popover', action: 'click@window->filter-popover#closeOnOutsideClick' }) do
      button(
        type:  'button',
        class: 'w-9 h-9 rounded-full bg-white border border-slate-200 shadow-sm flex items-center justify-center ' \
               'text-slate-600 focus:outline-none focus:ring-2 focus:ring-blue-500 cursor-pointer',
        title: t('.title'),
        data:  { action: 'click->filter-popover#toggle' }
      ) { render PhlexIcons::Lucide::Funnel.new(class: 'w-[18px] h-[18px]') }

      div(
        class: 'hidden absolute right-0 top-full mt-2 z-30 w-48 bg-white rounded-xl shadow-xl border border-slate-200 p-1.5',
        data:  { filter_popover_target: 'panel' }
      ) { popover_panel }
    end
  end

  def popover_panel
    form(action: target_path, method: 'get', class: 'px-2.5 pt-1 pb-1.5', data: { controller: 'filter' }) do
      select(
        name:         'year',
        'aria-label': t('.year'),
        class:        'appearance-none bg-transparent text-[11px] font-semibold text-slate-400 uppercase tracking-wide ' \
                      'focus:outline-none cursor-pointer',
        data:         { filter_target: 'year', action: 'change->filter#submit' }
      ) { year_options }
    end
    a(href: period_path(nil), class: "block w-full text-left px-2.5 py-2 rounded-lg text-sm #{month_link_state(nil, :all)}") do
      t('.all_months')
    end
    div(class: 'grid grid-cols-3 gap-1 mt-1') do
      selectable_months.each do |month|
        a(href: period_path(month), class: "#{MONTH_LINK} #{month_link_state(month, :month)}") do
          I18n.t('date.abbr_month_names')[month].capitalize
        end
      end
    end
  end

  def month_link_state(month, kind)
    return 'text-slate-700 hover:bg-slate-50' unless month.to_s == @selected_month.to_s
    return 'bg-blue-50 text-blue-700 font-semibold' if kind == :all

    'bg-blue-600 text-white font-semibold'
  end

  def selectable_months
    last = @selected_year.to_i == Date.current.year ? Date.current.month : 12
    (1..last)
  end

  def period_path(month)
    "#{target_path}?#{{ year: @selected_year, month: month }.compact.to_query}"
  end

  def target_path
    @action_path || root_path
  end

  def year_options
    @available_years.each do |year|
      option(value: year, selected: year.to_s == @selected_year.to_s) { year }
    end
  end

  def month_options
    option(value: '', selected: @selected_month.nil?) { t('.all_months') }

    (1..12).each do |month_index|
      option(value: month_index, selected: month_index.to_s == @selected_month.to_s) do
        I18n.t('date.month_names')[month_index].capitalize
      end
    end
  end
end
