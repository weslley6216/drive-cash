module Notifications
  class IndexView < ApplicationView
    READ_ALL_MOBILE_CLASSES = 'text-xs font-semibold text-blue-600 mt-2 whitespace-nowrap cursor-pointer'
    READ_ALL_DESKTOP_CLASSES = 'flex items-center gap-2 bg-white border border-slate-200 rounded-lg px-3.5 py-2 ' \
                               'text-sm font-medium text-slate-700 hover:bg-slate-50 cursor-pointer'

    def initialize(groups:, unread_count:)
      @groups = groups
      @unread_count = unread_count
    end

    def view_template
      render LayoutComponent.new(title: t('notifications.index.title'), bottom_nav: :more, sidebar_nav: :more) do
        div(id: 'flash') { render FlashComponent.new(flash: helpers.flash) }
        mobile_header
        desktop_header
        @groups.empty? ? empty_state : groups_list
      end
    end

    private

    def mobile_header
      div(class: 'lg:hidden px-5 pt-2 pb-3 flex items-start justify-between gap-3') do
        div(class: 'flex items-start gap-2') do
          link_to(helpers.account_path,
                  class: 'p-1 -ml-1 mt-0.5 text-slate-500',
                  aria:  { label: t('notifications.index.back') }) do
            render PhlexIcons::Lucide::ArrowLeft.new(class: 'w-[22px] h-[22px]')
          end
          h1(class: 'text-2xl font-bold text-slate-800') { t('notifications.index.title') }
        end
        read_all_button(css: READ_ALL_MOBILE_CLASSES) unless @groups.empty?
      end
    end

    def desktop_header
      div(class: 'hidden lg:flex items-center justify-between mb-6') do
        div do
          h1(class: 'text-2xl font-bold text-slate-800') { t('notifications.index.title') }
          p(class: 'text-sm text-slate-500 mt-1') { t('notifications.index.unread_count', count: @unread_count) }
        end
        unless @groups.empty?
          read_all_button(css: READ_ALL_DESKTOP_CLASSES) do
            render PhlexIcons::Lucide::Check.new(class: 'w-[15px] h-[15px] text-slate-500')
          end
        end
      end
    end

    def read_all_button(css:, &block)
      button_to(helpers.read_all_notifications_path, method: :patch, class: css, form_class: 'contents') do
        block&.call
        plain t('notifications.index.read_all')
      end
    end

    def groups_list
      div(class: 'px-5 lg:px-0 pb-10 max-w-2xl space-y-5') do
        @groups.each { |group| group_block(group) }
      end
    end

    def group_block(group)
      div do
        p(class: 'text-xs font-semibold text-slate-400 uppercase tracking-wider mb-2 px-1') do
          t("notifications.index.groups.#{group.key}")
        end
        div(class: 'bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden') do
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
