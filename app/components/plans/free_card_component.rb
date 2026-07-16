module Plans
  class FreeCardComponent < ApplicationComponent
    def initialize(comparison:)
      @comparison = comparison
    end

    def view_template
      div(class: 'bg-white rounded-2xl border border-slate-200 p-5') do
        heading
        p(class: 'text-3xl font-bold tracking-tight text-slate-900 mb-1') { format_currency_short(@comparison.free_price_month) }
        p(class: 'text-xs text-slate-500 mb-4') { t('plans.free_card.forever') }
        render BenefitListComponent.new(features: @comparison.free_features, muted: true)
      end
    end

    private

    def heading
      div(class: 'flex items-center justify-between mb-3') do
        p(class: 'text-sm font-bold text-slate-800') { t('plans.names.free') }
        span(class: 'text-[10px] font-bold uppercase tracking-wide text-slate-600 bg-slate-100 border border-slate-200 rounded-full px-2 py-0.5') do
          t('plans.free_card.badge')
        end
      end
    end
  end
end
