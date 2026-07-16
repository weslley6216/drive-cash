module Notifications
  class RowComponent < ApplicationComponent
    include Phlex::Rails::Helpers::ButtonTo

    PALETTES = {
      danger:  'bg-red-50 text-red-600',
      warning: 'bg-amber-50 text-amber-500',
      success: 'bg-emerald-50 text-emerald-500',
      info:    'bg-blue-50 text-blue-600',
      neutral: 'bg-slate-100 text-slate-500'
    }.freeze

    TIME_FORMATS = {
      today:   :notification_time,
      week:    :notification_weekday,
      earlier: :notification_date
    }.freeze

    def initialize(row:, bucket:, last: false)
      @row = row
      @bucket = bucket
      @last = last
    end

    def view_template
      button_to(read_notification_path(notification), method: :patch, class: row_classes, form_class: 'contents') do
        icon_tile
        content
        span(class: 'text-[10px] text-slate-400 whitespace-nowrap mt-0.5') { timestamp }
      end
    end

    private

    def notification = @row.notification

    def row_classes
      class_names(
        'w-full flex items-start gap-3 px-4 py-3.5 text-left hover:bg-slate-50 cursor-pointer',
        ('border-b border-slate-100' unless @last),
        ('bg-blue-50/40' if notification.unread?)
      )
    end

    def icon_tile
      div(class: "w-9 h-9 rounded-lg flex items-center justify-center flex-shrink-0 #{palette_classes}") do
        render @row.icon.new(class: 'w-[17px] h-[17px]')
      end
    end

    def palette_classes
      PALETTES.fetch(@row.palette_key, PALETTES[:neutral])
    end

    def content
      div(class: 'flex-1 min-w-0') do
        div(class: 'flex items-center gap-2') do
          p(class: title_classes) { @row.title }
          span(class: 'w-2 h-2 rounded-full bg-blue-600 flex-shrink-0') if notification.unread?
        end
        p(class: 'text-xs text-slate-500 mt-0.5 leading-snug') { @row.body }
      end
    end

    def title_classes
      class_names('text-sm text-slate-800 truncate', notification.unread? ? 'font-bold' : 'font-medium')
    end

    def timestamp
      l(notification.created_at, format: TIME_FORMATS.fetch(@bucket))
    end
  end
end
