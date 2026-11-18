module Records
  class DetailsSectionComponent < ApplicationComponent
    CARD = "#{CardStyles::CARD} p-3 lg:bg-slate-50 lg:border-slate-200 lg:shadow-none".freeze
    LABEL = 'text-[10px] font-medium text-slate-500 uppercase tracking-wide mb-1 block lg:font-semibold lg:mb-0'.freeze

    def view_template(&block)
      div(class: 'mt-5 space-y-3') do
        p(class: 'text-xs font-bold text-slate-500 uppercase tracking-wider lg:hidden') { t('records.new_view.details') }
        div(class: 'space-y-3 lg:space-y-0 lg:grid lg:grid-cols-2 lg:gap-3', &block)
      end
    end
  end
end
