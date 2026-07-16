module Plans
  class PriceToggleComponent < ApplicationComponent
    ACTIVE_CLASSES = 'bg-white text-slate-900 shadow-sm'.freeze
    IDLE_CLASSES = 'text-slate-500'.freeze

    def initialize(discount_percent:)
      @discount_percent = discount_percent
    end

    def view_template
      div(class: 'inline-flex bg-slate-100 border border-slate-200 rounded-full p-1 text-sm font-semibold') do
        monthly_button
        yearly_button
      end
    end

    private

    def monthly_button
      button(type:  'button',
             class: "px-4 py-1.5 rounded-full cursor-pointer #{IDLE_CLASSES}",
             data:  { plan_billing_target: 'monthlyButton', action: 'click->plan-billing#showMonthly' }) do
        t('plans.toggle.monthly')
      end
    end

    def yearly_button
      button(type:  'button',
             class: "px-4 py-1.5 rounded-full flex items-center gap-1.5 cursor-pointer #{ACTIVE_CLASSES}",
             data:  { plan_billing_target: 'yearlyButton', action: 'click->plan-billing#showYearly' }) do
        plain t('plans.toggle.yearly')
        span(class: 'text-[10px] font-bold text-emerald-700 bg-emerald-50 border border-emerald-200 rounded-full px-1.5 py-px') do
          t('plans.toggle.discount', pct: @discount_percent)
        end
      end
    end
  end
end
