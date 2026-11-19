class DesktopBellComponent < ApplicationComponent
  BASE_CLASSES = 'relative w-10 h-10 rounded-lg flex items-center justify-center'
  ACTIVE_CLASSES = 'bg-blue-50 text-blue-700'
  INACTIVE_CLASSES = 'text-slate-600 hover:bg-slate-50'
  BADGE_CLASSES = 'absolute top-1.5 right-1.5 min-w-[16px] h-4 px-1 rounded-full bg-red-500 ' \
                  'text-white text-[10px] font-bold leading-4 text-center ring-2 ring-white'

  def initialize(unread_count:, active: false)
    @unread_count = unread_count
    @active = active
  end

  def view_template
    link_to(notifications_path, class: button_classes, aria: aria_options, data: { turbo_frame: '_top' }) do
      render PhlexIcons::Lucide::Bell.new(class: 'w-5 h-5')
      span(class: BADGE_CLASSES) { @unread_count.to_s } if @unread_count.positive? && !@active
    end
  end

  private

  def button_classes
    "#{BASE_CLASSES} #{@active ? ACTIVE_CLASSES : INACTIVE_CLASSES}"
  end

  def aria_options
    label = @unread_count.positive? ? t('.label_unread', count: @unread_count) : t('.label')
    @active ? { label: label, current: 'page' } : { label: label }
  end
end
