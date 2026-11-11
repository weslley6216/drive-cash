module Notifications
  class RowComponent < ApplicationComponent
    include Phlex::Rails::Helpers::ButtonTo

    TIME_FORMATS = {
      today:   :notification_time,
      week:    :notification_weekday,
      earlier: :notification_date
    }.freeze

    MENU_PANEL_CLASSES = 'hidden absolute right-1 top-9 z-10 w-[210px] bg-white rounded-xl border ' \
                          'border-slate-200 shadow-lg py-1'
    MENU_BUTTON_CLASSES = 'w-8 h-8 -mt-1 rounded-full flex items-center justify-center text-slate-400 ' \
                          'flex-shrink-0 focus:bg-slate-100 focus:text-slate-600'
    REMOVE_BUTTON_CLASSES = 'w-full flex items-center gap-2.5 px-3.5 py-2.5 text-sm text-slate-700 ' \
                            'hover:bg-slate-50 cursor-pointer'

    def initialize(row:, bucket:, last: false)
      @row = row
      @bucket = bucket
      @last = last
    end

    def view_template
      div(class: row_classes) do
        icon_tile
        content
        menu
      end
    end

    private

    def notification = @row.notification

    def row_classes
      class_names(
        'relative flex items-start gap-3 pl-4 pr-2 py-3.5 first:rounded-t-xl last:rounded-b-xl',
        ('border-b border-slate-100' unless @last),
        ('bg-blue-50/40' if notification.unread?)
      )
    end

    def icon_tile
      render IconTileComponent.new(icon: @row.icon, palette_key: @row.palette_key)
    end

    def content
      div(class: 'flex-1 min-w-0') do
        open_link
        p(class: 'text-xs text-slate-500 mt-0.5 leading-snug') { @row.body }
        p(class: 'text-[10px] text-slate-400 mt-1') { timestamp }
        inline_action_link
      end
    end

    def open_link
      link_to(open_notification_path(notification),
              class: 'block after:absolute after:inset-0',
              data:  { turbo_method: :patch, turbo_frame: @row.frame }) do
        div(class: 'flex items-center gap-2 min-w-0') do
          p(class: title_classes) { @row.title }
          span(class: 'w-2 h-2 rounded-full bg-blue-600 flex-shrink-0') if notification.unread?
        end
      end
    end

    def title_classes
      class_names('text-sm text-slate-800 truncate min-w-0', notification.unread? ? 'font-bold' : 'font-medium')
    end

    def timestamp
      l(notification.created_at, format: TIME_FORMATS.fetch(@bucket))
    end

    def inline_action_link
      inline_action = @row.inline_action
      return unless inline_action

      link_to(open_notification_path(notification, via: 'inline'),
              class: 'relative z-10 inline-flex mt-2 px-3 py-1.5 rounded-lg bg-white border border-slate-200 ' \
                     'text-xs font-semibold text-slate-700 shadow-sm',
              data:  { turbo_method: :patch, turbo_frame: inline_action.frame }) { inline_action.label }
    end

    def menu
      div(class: 'relative z-10 flex-shrink-0',
          data:  { controller: 'filter-popover', action: 'click@window->filter-popover#closeOnOutsideClick' }) do
        menu_button
        menu_panel
      end
    end

    def menu_button
      button(
        type:  'button',
        class: MENU_BUTTON_CLASSES,
        aria:  { label: t('notifications.menu.label') },
        data:  { action: 'click->filter-popover#toggle' }
      ) { render PhlexIcons::Lucide::Ellipsis.new(class: 'w-4 h-4') }
    end

    def menu_panel
      div(class: MENU_PANEL_CLASSES, data: { filter_popover_target: 'panel' }) do
        button_to(notification_path(notification), method: :delete, class: REMOVE_BUTTON_CLASSES,
                                                    form_class: 'contents') do
          render PhlexIcons::Lucide::Trash2.new(class: 'w-[15px] h-[15px] text-slate-400')
          plain " #{t('notifications.menu.remove')}"
        end
      end
    end
  end
end
