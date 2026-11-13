module NotificationPreferences
  class EditView < ApplicationView
    include TopbarStyles

    def initialize(rows:)
      @rows = rows
    end

    def view_template
      render LayoutComponent.new(title: t('notifications.preferences.title'), bottom_nav: :more, sidebar_nav: :more,
                                 turbo_cache: false, app_shell: true) do
        render ScreenComponent.new do |screen|
          screen.with_header { mobile_header }
          screen.with_content do
            div(class: 'lg:max-w-2xl lg:mx-auto') do
              desktop_header
              div(class: 'space-y-3') do
                list
                mobile_note
              end
              desktop_note
            end
          end
        end
      end
    end

    private

    def mobile_header
      div(class: "#{PHONE_BAR} flex items-start gap-2 lg:hidden") do
        link_to(notifications_path, class: 'p-1 -ml-1 mt-0.5 text-slate-500',
                                    aria:  { label: t('notifications.preferences.back') }) do
          render PhlexIcons::Lucide::ArrowLeft.new(class: 'w-[22px] h-[22px]')
        end
        div do
          h1(class: 'text-2xl font-bold text-slate-800') { t('notifications.preferences.title') }
          p(class: 'text-sm text-slate-500') { t('notifications.preferences.mobile_subtitle') }
        end
      end
    end

    def desktop_header
      div(class: 'hidden lg:block') do
        breadcrumb
        h1(class: 'text-2xl font-bold text-slate-800 mt-2') { t('notifications.preferences.title') }
        p(class: 'text-sm text-slate-500 mt-1 mb-6') { t('notifications.preferences.desktop_subtitle') }
      end
    end

    def breadcrumb
      div(class: 'flex text-xs text-slate-500 items-center gap-1') do
        plain t('notifications.preferences.breadcrumb.account')
        render PhlexIcons::Lucide::ChevronRight.new(class: 'w-3 h-3')
        plain t('notifications.preferences.breadcrumb.notifications')
        render PhlexIcons::Lucide::ChevronRight.new(class: 'w-3 h-3')
        plain t('notifications.preferences.title')
      end
    end

    def list
      div(class: 'bg-white rounded-xl shadow-sm border border-slate-100') do
        @rows.each_with_index { |row, index| render Notifications::PreferenceRowComponent.new(row: row, first: index.zero?) }
      end
    end

    def mobile_note
      p(class: 'lg:hidden text-[11px] text-slate-500 px-1 leading-relaxed') { t('notifications.preferences.mobile_note') }
    end

    def desktop_note
      p(class: 'hidden lg:block text-xs text-slate-500 mt-3') { t('notifications.preferences.desktop_note') }
    end
  end
end
