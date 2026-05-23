class CajuQuickAccessComponent < ApplicationComponent
  def view_template
    link_to(
      chat_root_path,
      class: 'block rounded-2xl bg-violet-50 border-2 border-violet-200 p-4 hover:bg-violet-100 transition-colors animate-slide-up'
    ) do
      div(class: 'flex items-center gap-3') do
        div(class: 'flex items-center justify-center w-10 h-10 rounded-full bg-violet-600 text-white shrink-0') do
          render PhlexIcons::Lucide::Sparkles.new(class: 'w-5 h-5')
        end
        div(class: 'flex-1') do
          p(class: 'text-sm font-semibold text-violet-900') { I18n.t('caju_quick_access_component.title') }
          p(class: 'text-xs text-violet-700 mt-0.5 opacity-80') { I18n.t('caju_quick_access_component.examples') }
        end
      end
    end
  end
end
