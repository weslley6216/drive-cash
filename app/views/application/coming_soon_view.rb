module Application
  class ComingSoonView < ApplicationComponent
    def view_template
      render LayoutComponent.new(title: I18n.t('application.coming_soon_view.title')) do
        div(class: 'flex flex-col items-center justify-center min-h-[60vh] text-center') do
          h1(class: 'text-3xl font-bold text-slate-800 mb-2') do
            I18n.t('application.coming_soon_view.title')
          end
          p(class: 'text-slate-600 mb-8') { I18n.t('application.coming_soon_view.message') }
          link_to(root_path, class: 'inline-block bg-blue-600 text-white px-6 py-3 rounded-lg font-medium') do
            I18n.t('application.coming_soon_view.back')
          end
        end
      end
    end
  end
end
