module Records
  class StickyActionBarComponent < ApplicationComponent
    THEMES = {
      red:     { bg: 'bg-red-600', shadow: 'shadow-red-600/20', label_key: 'records.new_view.save_expense' },
      emerald: { bg: 'bg-emerald-600', shadow: 'shadow-emerald-600/20', label_key: 'records.new_view.save_earning' }
    }.freeze

    def initialize(theme:)
      @theme = theme.to_sym
    end

    def view_template
      style = THEMES.fetch(@theme)
      div(class: 'px-5 pt-3 pb-6 border-t border-slate-100 bg-white sticky bottom-0 lg:static lg:px-6 lg:py-4 lg:flex lg:items-center lg:justify-end lg:gap-3') do
        link_to(t('records.new_view.cancel'), root_path, class: 'hidden lg:inline px-4 py-2 text-sm font-medium text-slate-600 hover:text-slate-900')
        button(
          type:  'submit',
          class: 'w-full rounded-xl py-3.5 text-base font-semibold text-white flex items-center justify-center gap-2 shadow-lg cursor-pointer ' \
                 "lg:w-auto lg:rounded-lg lg:px-5 lg:py-2 lg:text-sm lg:shadow-none #{style[:bg]} #{style[:shadow]}",
          data:  { record_form_target: 'submit' }
        ) do
          render PhlexIcons::Lucide::Save.new(class: 'w-5 h-5 lg:w-[15px] lg:h-[15px]')
          span { t(style[:label_key]) }
        end
      end
    end
  end
end
