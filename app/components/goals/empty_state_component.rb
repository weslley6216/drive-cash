module Goals
  class EmptyStateComponent < ApplicationComponent
    def view_template
      div(class: 'bg-white rounded-2xl border border-dashed border-slate-300 p-8 text-center space-y-4') do
        div(class: 'mx-auto w-12 h-12 rounded-full bg-blue-50 flex items-center justify-center') do
          render PhlexIcons::Lucide::Target.new(class: 'w-6 h-6 text-blue-600')
        end
        h2(class: 'text-lg font-semibold text-slate-900') { t('goals.index.empty.title') }
        p(class: 'text-sm text-slate-500') { t('goals.index.empty.subtitle') }
        link_to(
          helpers.new_goal_path,
          data:  { turbo_frame: 'modal' },
          class: 'inline-flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg px-4 py-2 text-sm font-semibold'
        ) do
          render PhlexIcons::Lucide::Plus.new(class: 'w-4 h-4')
          plain t('goals.index.empty.cta')
        end
      end
    end
  end
end
