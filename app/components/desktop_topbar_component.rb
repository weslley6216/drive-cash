class DesktopTopbarComponent < ApplicationComponent
  HEADER_CLASSES = 'hidden lg:flex -mx-8 bg-white border-b border-slate-200 px-8 py-4 items-center justify-between gap-6'
  ACTIONS_CLASSES = 'flex items-center gap-3 flex-shrink-0'
  DIVIDER_CLASSES = 'w-px h-6 bg-slate-200'

  def initialize(title:, subtitle:, unread_count:, bell_active: false, back: nil)
    @title = title
    @subtitle = subtitle
    @unread_count = unread_count
    @bell_active = bell_active
    @back = back
  end

  def view_template(&)
    vanish(&)

    header(class: HEADER_CLASSES) do
      div(class: 'min-w-0') do
        back_link if @back
        h1(class: 'text-2xl font-bold text-slate-900 tracking-tight') { @title }
        p(class: 'text-sm text-slate-500 mt-0.5') { @subtitle }
      end
      div(class: ACTIONS_CLASSES) do
        render @actions if @actions
        span(class: DIVIDER_CLASSES) if @actions
        render DesktopBellComponent.new(unread_count: @unread_count, active: @bell_active)
      end
    end
  end

  def with_actions(&block)
    @actions = block
  end

  private

  def back_link
    link_to(@back[:path], class: 'flex items-center gap-1 text-xs font-semibold text-slate-500 hover:text-slate-800 mb-1') do
      render PhlexIcons::Lucide::ArrowLeft.new(class: 'w-3.5 h-3.5')
      plain @back[:label]
    end
  end
end
