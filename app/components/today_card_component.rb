class TodayCardComponent < ApplicationComponent
  def initialize(earnings:, expenses:, net:, trips_count: 0)
    @earnings = earnings
    @expenses = expenses
    @net = net
    @trips_count = trips_count.to_i
  end

  def view_template
    div(class: 'rounded-2xl bg-white border border-slate-200 p-4 lg:p-5') do
      p(class: 'text-xs font-semibold uppercase tracking-wider text-slate-500') { t('.label') }
      p(class: 'text-2xl lg:text-3xl font-bold text-slate-900 mt-1 tabular-nums tracking-tight') do
        format_currency(@net)
      end

      div(class: 'flex items-center gap-3 text-xs mt-2 flex-wrap') do
        span(class: 'text-emerald-600 font-medium tabular-nums') { "+#{format_currency(@earnings)}" }
        span(class: 'text-red-600 font-medium tabular-nums')     { "−#{format_currency(@expenses)}" }
        span(class: 'text-slate-400 ml-auto') { detail_text } if detail_text.present?
      end
    end
  end

  private

  def detail_text
    parts = []
    parts << I18n.t('today_card_component.trips_count', count: @trips_count) if @trips_count.positive?
    parts.join(' · ').presence
  end
end
