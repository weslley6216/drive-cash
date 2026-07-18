module Dashboard
  class EmptyHeroComponent < ApplicationComponent
    def initialize(year:)
      @year = year
    end

    def view_template
      div(class: 'rounded-2xl bg-white border-2 border-dashed border-slate-200 p-5') do
        p(class: 'text-xs font-medium text-slate-400 uppercase tracking-wider') do
          t('empty_states.home.hero_label', year: @year)
        end
        p(class: 'text-3xl font-bold mt-1 tracking-tight text-slate-300') do
          t('empty_states.home.hero_placeholder')
        end
        p(class: 'text-sm text-slate-400 mt-1') { t('empty_states.home.hero_hint') }
      end
    end
  end
end
