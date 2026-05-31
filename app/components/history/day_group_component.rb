module History
  class DayGroupComponent < ApplicationComponent
    def initialize(group:, context:)
      @group   = group
      @context = context
    end

    def view_template
      section(id: section_id, class: 'mb-5') do
        header
        list
      end
    end

    private

    def section_id
      "day-#{@group[:date].strftime('%Y-%m-%d')}"
    end

    def header
      div(class: 'flex items-center justify-between mb-2 px-1') do
        span(class: 'text-xs font-semibold uppercase tracking-wider text-slate-500') { date_label }
        div(class: 'flex items-center gap-2 text-xs font-semibold') do
          earnings_chip if @group[:earnings_total].to_f > 0
          expenses_chip if @group[:expenses_total].to_f > 0
        end
      end
    end

    def earnings_chip
      span(class: 'text-emerald-700') { "+ #{format_currency(@group[:earnings_total])}" }
    end

    def expenses_chip
      span(class: 'text-red-700') { "− #{format_currency(@group[:expenses_total])}" }
    end

    def list
      div(class: 'bg-white border border-slate-200 rounded-xl divide-y divide-slate-100 overflow-hidden') do
        @group[:items].each do |record|
          render History::EntryRowComponent.new(record: record, context: @context)
        end
      end
    end

    def date_label
      return I18n.t('common.today')     if @group[:date] == Date.current
      return I18n.t('common.yesterday') if @group[:date] == Date.current - 1

      I18n.l(@group[:date], format: :short)
    end
  end
end
