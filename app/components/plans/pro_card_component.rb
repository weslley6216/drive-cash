module Plans
  class ProCardComponent < ApplicationComponent
    def initialize(comparison:)
      @comparison = comparison
    end

    def view_template
      div(class: 'relative bg-white rounded-2xl border-2 border-blue-600 shadow-lg shadow-blue-600/10 p-5') do
        span(class: 'absolute -top-2.5 left-4 text-[10px] font-bold uppercase tracking-wide text-white bg-blue-600 rounded-full px-2.5 py-0.5') do
          t('plans.pro_card.recommended')
        end
        heading
        prices
        div(class: 'mt-4') { render BenefitListComponent.new(features: @comparison.pro_features) }
        subscribe_button
        p(class: 'text-center text-[11px] text-slate-400 mt-2.5') { t('plans.pro_card.cancel_anytime') }
      end
    end

    private

    def heading
      div(class: 'flex items-center justify-between mb-3 mt-1') do
        p(class: 'text-sm font-bold text-blue-700') { t('plans.names.pro') }
        render PhlexIcons::Lucide::Zap.new(class: 'w-4 h-4 text-blue-600')
      end
    end

    def prices
      div do
        price(billing: 'yearly', amount: @comparison.pro_monthly_equivalent, hidden: false,
              footnote: t('plans.pro_card.charged_yearly', price: format_currency(@comparison.pro_price_year)))
        price(billing: 'monthly', amount: @comparison.pro_price_month, hidden: true,
              footnote: t('plans.pro_card.charged_monthly'))
      end
    end

    def price(billing:, amount:, hidden:, footnote:)
      div(class: (hidden ? 'hidden' : nil), data: { plan_billing_target: "#{billing}Price" }) do
        div(class: 'flex items-baseline gap-1.5') do
          span(class: 'text-3xl font-bold tracking-tight text-slate-900 tabular-nums') { format_currency(amount) }
          span(class: 'text-sm text-slate-500') { t('plans.pro_card.per_month') }
        end
        p(class: 'text-xs text-slate-500 mt-1') { footnote }
      end
    end

    def subscribe_button
      link_to(t('plans.pro_card.cta'), helpers.plan_path,
              class: 'mt-5 w-full block text-center bg-blue-600 hover:bg-blue-700 text-white rounded-xl py-3.5 text-sm font-bold shadow-sm',
              data:  { turbo_method: :patch })
    end
  end
end
