module Goals
  class SuggestionCardComponent < ApplicationComponent
    include CardStyles

    def initialize(amount:)
      @amount = amount
    end

    def view_template
      div(class: "#{CARD} p-4") do
        p(class: 'text-xs font-semibold text-slate-400 uppercase tracking-wider mb-1.5') { t('goals.index.suggestion.label') }
        p(class: 'text-sm text-slate-600 leading-relaxed') do
          plain t('goals.index.suggestion.text_before')
          span(class: 'font-bold text-slate-800') { format_currency(@amount) }
          plain t('goals.index.suggestion.text_after')
        end
      end
    end
  end
end
