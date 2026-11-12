module Notifications
  class IndexView < ApplicationView
    HEADER_ACTION_MOBILE_CLASSES = 'text-xs font-semibold text-blue-600 mt-2 text-right cursor-pointer'
    HEADER_ACTION_DESKTOP_CLASSES = 'flex items-center gap-2 bg-white border border-slate-200 rounded-lg px-3.5 ' \
                                     'py-2 text-sm font-medium text-slate-700 hover:bg-slate-50 cursor-pointer'
    PREFERENCES_MOBILE_CLASSES = 'w-9 h-9 rounded-full bg-white border border-slate-200 shadow-sm flex ' \
                                 'items-center justify-center text-slate-600'
    PREFERENCES_DESKTOP_CLASSES = 'w-9 h-9 rounded-lg bg-white border border-slate-200 flex items-center ' \
                                  'justify-center text-slate-600 hover:bg-slate-50'

    def initialize(groups:, unread_count:)
      @groups = groups
      @unread_count = unread_count
    end

    def view_template
      render LayoutComponent.new(title: t('notifications.index.title'), bottom_nav: :more, sidebar_nav: :more,
                                 turbo_cache: false) do
        div(id: 'flash') { render FlashComponent.new(flash: helpers.flash) }
        mobile_header
        desktop_header
        @groups.empty? ? empty_state : groups_list
        turbo_frame_tag 'modal'
      end
    end

    private

    def mobile_header
      div(class: 'lg:hidden px-1 pt-2 pb-3') do
        div(class: 'flex items-start justify-between gap-3') do
          div(class: 'flex items-start gap-2') do
            link_to(helpers.account_path,
                    class: 'p-1 -ml-1 mt-0.5 text-slate-500',
                    aria:  { label: t('notifications.index.back') }) do
              render PhlexIcons::Lucide::ArrowLeft.new(class: 'w-[22px] h-[22px]')
            end
            h1(class: 'text-2xl font-bold text-slate-800') { t('notifications.index.title') }
          end
          preferences_link(css: PREFERENCES_MOBILE_CLASSES)
        end
        div(class: 'flex justify-end px-1 mb-2') { header_action(css: HEADER_ACTION_MOBILE_CLASSES) } unless @groups.empty?
      end
    end

    def desktop_header
      div(class: 'hidden lg:flex items-center justify-between mb-6') do
        div do
          h1(class: 'text-2xl font-bold text-slate-800') { t('notifications.index.title') }
          p(class: 'text-sm text-slate-500 mt-1') { t('notifications.index.unread_count', count: @unread_count) }
        end
        div(class: 'flex items-center gap-2') do
          unless @groups.empty?
            header_action(css: HEADER_ACTION_DESKTOP_CLASSES, icon_class: 'w-[15px] h-[15px] text-slate-500')
          end
          preferences_link(css: PREFERENCES_DESKTOP_CLASSES)
        end
      end
    end

    def preferences_link(css:)
      link_to(helpers.edit_notification_preferences_path, class: css,
                                                          aria:  { label: t('notifications.index.preferences') }) do
        render PhlexIcons::Lucide::Settings.new(class: 'w-[17px] h-[17px]')
      end
    end

    def header_action(css:, icon_class: nil)
      if @unread_count.positive?
        header_button(helpers.read_all_notifications_path, :patch, 'read_all', css: css) do
          render PhlexIcons::Lucide::Check.new(class: icon_class) if icon_class
        end
      else
        header_button(helpers.clear_notifications_path, :delete, 'clear_all', css: css) do
          render PhlexIcons::Lucide::Trash2.new(class: icon_class) if icon_class
        end
      end
    end

    def header_button(path, method, label_key, css:, &icon)
      button_to(path, method: method, class: css, form_class: 'contents') do
        icon.call
        plain t("notifications.index.#{label_key}")
      end
    end

    def groups_list
      div(class: 'px-1 lg:px-0 pb-10 max-w-2xl space-y-5') do
        @groups.each { |group| group_block(group) }
      end
    end

    def group_block(group)
      div do
        p(class: 'text-xs font-semibold text-slate-400 uppercase tracking-wider mb-2 px-1') do
          t("notifications.index.groups.#{group.key}")
        end
        div(class: 'bg-white rounded-xl shadow-sm border border-slate-100') do
          group.rows.each_with_index do |row, index|
            render RowComponent.new(row: row, bucket: group.key, last: index == group.rows.size - 1)
          end
        end
      end
    end

    def empty_state
      div(class: 'flex flex-col items-center justify-center text-center px-8 py-16') do
        div(class: 'w-20 h-20 rounded-full bg-slate-100 border border-slate-200 flex items-center justify-center mb-5') do
          render PhlexIcons::Lucide::Bell.new(class: 'w-8 h-8 text-slate-400')
        end
        h2(class: 'text-lg font-bold text-slate-800') { t('notifications.index.empty.title') }
        p(class: 'text-sm text-slate-500 mt-2 max-w-[240px] leading-relaxed') { t('notifications.index.empty.description') }
      end
    end
  end
end
