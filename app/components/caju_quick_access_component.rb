class CajuQuickAccessComponent < ApplicationComponent
  def view_template
    div(class: 'lg:hidden') do
      link_to chat_root_path, class: mobile_classes do
        div(class: 'w-10 h-10 rounded-full bg-violet-100 flex items-center justify-center text-violet-600 flex-shrink-0') do
          render PhlexIcons::Lucide::Sparkles.new(class: 'w-5 h-5')
        end
        div(class: 'flex-1 min-w-0') do
          p(class: 'text-sm font-semibold text-slate-800') { t('.title') }
          p(class: 'text-xs text-slate-500 truncate') { t('.examples') }
        end
        render PhlexIcons::Lucide::Mic.new(class: 'w-[18px] h-[18px] text-violet-500')
      end
    end

    div(class: 'hidden lg:block h-full') do
      link_to chat_root_path, class: desktop_classes do
        div(class: 'flex items-center justify-between') do
          render PhlexIcons::Lucide::Sparkles.new(class: 'w-7 h-7')
          render PhlexIcons::Lucide::ArrowUpRight.new(class: 'w-5 h-5')
        end
        p(class: 'text-lg font-bold mt-4') { t('.title') }
        p(class: 'text-sm text-violet-100 mt-1 leading-relaxed') { t('.cta_desktop') }
      end
    end
  end

  private

  def mobile_classes
    'w-full flex items-center gap-3 bg-white border border-violet-100 rounded-2xl p-3.5 shadow-sm text-left hover:border-violet-200'
  end

  def desktop_classes
    'flex flex-col h-full rounded-2xl bg-gradient-to-br from-violet-500 to-fuchsia-600 ' \
    'text-white p-5 text-left shadow-lg shadow-violet-500/20 hover:from-violet-600 hover:to-fuchsia-700'
  end
end
