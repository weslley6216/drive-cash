module WeeklySummaries
  class HeroComponent < ApplicationComponent
    def initialize(summary:)
      @summary = summary
    end

    def view_template
      div(class: 'bg-white rounded-xl shadow-sm border border-slate-100 p-4') do
        p(class: 'text-xs font-medium text-slate-500') { t('weekly_summaries.show.profit') }
        p(class: 'text-3xl font-bold text-slate-900 mt-1 tabular-nums') { format_currency(@summary.profit) }
        earnings_and_expenses
        div(class: 'grid grid-cols-3 gap-2 mt-4 pt-4 border-t border-slate-100') do
          metric(t('weekly_summaries.show.trips'), @summary.trips)
          metric(t('weekly_summaries.show.days_worked'), @summary.days_worked)
          metric(t('weekly_summaries.show.per_km'), per_km_text)
        end
      end
    end

    private

    def earnings_and_expenses
      p(class: 'text-xs text-slate-500 mt-1 tabular-nums') do
        span(class: 'text-emerald-700 font-semibold') { "+#{format_currency(@summary.earnings_total)}" }
        plain " #{t('weekly_summaries.show.earnings')}"
        span(class: 'text-slate-300 mx-1.5') { '·' }
        span(class: 'text-red-700 font-semibold') { "−#{format_currency(@summary.expenses_total)}" }
        plain " #{t('weekly_summaries.show.expenses')}"
      end
    end

    def metric(label, value)
      div do
        p(class: 'text-[11px] text-slate-500') { label }
        p(class: 'text-base font-bold text-slate-800') { value.to_s }
      end
    end

    def per_km_text
      @summary.per_km ? format_currency(@summary.per_km) : t('weekly_summaries.show.empty_value')
    end
  end
end
