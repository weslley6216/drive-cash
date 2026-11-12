class RecentActivityComponent < ApplicationComponent
  STYLES = {
    earning: {
      icon:         PhlexIcons::Lucide::Truck,
      icon_bg:      'bg-emerald-50',
      icon_color:   'text-emerald-600',
      amount_color: 'text-emerald-700',
      sign:         '+'
    },
    expense: {
      icon:         PhlexIcons::Lucide::Receipt,
      icon_bg:      'bg-red-50',
      icon_color:   'text-red-600',
      amount_color: 'text-red-700',
      sign:         "\u2212"
    }
  }.freeze

  def initialize(rows:)
    @rows = rows
  end

  def view_template
    section(class: 'animate-slide-up') do
      header
      @rows.empty? ? empty_state : list
    end
  end

  private

  def header
    div(class: 'flex items-center justify-between mb-2 px-1 lg:mb-3 lg:px-0') do
      h2(class: 'text-sm font-semibold text-slate-700 lg:text-base lg:text-slate-800') { I18n.t('recent_activity_component.title') }
      a(href: helpers.history_path, class: 'text-xs font-medium text-blue-600 lg:text-sm lg:hover:underline') do
        span(class: 'lg:hidden') { I18n.t('recent_activity_component.see_all') }
        span(class: 'hidden lg:inline') { I18n.t('recent_activity_component.see_all_desktop') }
      end
    end
  end

  def empty_state
    p(class: 'text-sm text-slate-500 bg-white border border-slate-200 rounded-lg px-4 py-6 text-center') do
      I18n.t('recent_activity_component.empty')
    end
  end

  def list
    div(class: 'bg-white rounded-xl shadow-sm border border-slate-100 lg:border-slate-200 lg:shadow-none divide-y divide-slate-100') do
      @rows.each { |row| activity_row(row) }
    end
  end

  def activity_row(row)
    style = STYLES.fetch(row[:type])

    div(class: 'flex items-center gap-3 px-4 py-3 lg:gap-4 lg:px-5 lg:py-3.5', data: { recent_activity_row: row[:type] }) do
      div(class: class_names('flex items-center justify-center w-9 h-9 lg:w-10 lg:h-10 rounded-lg shrink-0', style[:icon_bg], style[:icon_color])) do
        render style[:icon].new(class: 'w-4 h-4 lg:w-[18px] lg:h-[18px]')
      end
      div(class: 'flex-1 min-w-0') do
        p(class: 'text-sm font-medium text-slate-800 lg:text-slate-900 truncate') { row[:label] }
        p(class: 'text-xs text-slate-500 truncate') do
          plain row[:description]
          span(class: 'lg:hidden') { " · #{row[:date_label]}" }
        end
      end
      span(class: 'hidden lg:block text-xs text-slate-400 w-20') { row[:date_label] }
      span(class: class_names('text-sm font-semibold whitespace-nowrap shrink-0 lg:tabular-nums lg:w-24 lg:text-right', style[:amount_color])) do
        "#{style[:sign]}#{format_currency(row[:amount])}"
      end
    end
  end
end
