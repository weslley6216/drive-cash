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
      sign:         '-'
    }
  }.freeze

  def initialize(rows:)
    @rows = rows
  end

  def view_template
    section(class: 'mt-6 animate-slide-up') do
      header
      @rows.empty? ? empty_state : list
    end
  end

  private

  def header
    div(class: 'flex items-center justify-between mb-3') do
      h2(class: 'text-base font-semibold text-slate-800') { I18n.t('recent_activity_component.title') }
    end
  end

  def empty_state
    p(class: 'text-sm text-slate-500 bg-white border border-slate-200 rounded-lg px-4 py-6 text-center') do
      I18n.t('recent_activity_component.empty')
    end
  end

  def list
    div(class: 'bg-white border border-slate-200 rounded-lg divide-y divide-slate-100') do
      @rows.each { |row| activity_row(row) }
    end
  end

  def activity_row(row)
    style = STYLES.fetch(row[:type])

    div(class: 'flex items-center gap-3 px-4 py-3', data: { recent_activity_row: row[:type] }) do
      div(class: class_names('flex items-center justify-center w-9 h-9 rounded-full shrink-0', style[:icon_bg], style[:icon_color])) do
        render style[:icon].new(class: 'w-4 h-4')
      end
      div(class: 'flex-1 min-w-0') do
        p(class: 'text-sm font-medium text-slate-900 truncate') { row[:label] }
        p(class: 'text-xs text-slate-500 truncate') { "#{row[:date_label]} · #{row[:description]}" }
      end
      span(class: class_names('text-sm font-semibold shrink-0', style[:amount_color])) do
        "#{style[:sign]} #{format_currency(row[:amount])}"
      end
    end
  end
end
