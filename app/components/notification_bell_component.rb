class NotificationBellComponent < ApplicationComponent
  BUTTON_CLASSES = 'relative w-9 h-9 rounded-full bg-white border border-slate-200 shadow-sm ' \
                   'flex items-center justify-center text-slate-600 hover:bg-slate-50'
  BADGE_CLASSES = 'absolute -top-0.5 -right-0.5 min-w-[16px] h-4 px-1 rounded-full bg-blue-600 ' \
                  'text-white text-[9px] font-bold flex items-center justify-center border-2 border-slate-50'

  def initialize(unread_count:)
    @unread_count = unread_count
  end

  def view_template
    link_to(notifications_path, class: BUTTON_CLASSES, aria: { label: t('notifications.index.title') }) do
      render PhlexIcons::Lucide::Bell.new(class: 'w-[18px] h-[18px]')
      span(class: BADGE_CLASSES) { @unread_count.to_s } if @unread_count.positive?
    end
  end
end
