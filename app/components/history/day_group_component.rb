module History
  class DayGroupComponent < ApplicationComponent
    include CardStyles

    def initialize(group:, context:)
      @group = group
      @context = context
    end

    def view_template
      section(id: section_id) do
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
        p(class: 'text-xs font-bold text-slate-500 uppercase tracking-wider') { date_label }
        p(class: 'text-xs font-medium text-slate-600') do
          earnings_total if earnings?
          span(class: 'text-slate-300 mx-1.5') { '·' } if earnings? && expenses?
          expenses_total if expenses?
        end
      end
    end

    def earnings?
      @group[:earnings_total].to_f.positive?
    end

    def expenses?
      @group[:expenses_total].to_f.positive?
    end

    def earnings_total
      span(class: 'text-emerald-700') { "+#{format_currency_short(@group[:earnings_total])}" }
    end

    def expenses_total
      span(class: 'text-red-700') { "−#{format_currency_short(@group[:expenses_total])}" }
    end

    def list
      div(class: "#{CARD} divide-y divide-slate-100 overflow-hidden") do
        @group[:items].each do |record|
          render History::EntryRowComponent.new(record: record, context: @context)
        end
      end
    end

    def date_label
      date = @group[:date]
      day_month = I18n.l(date, format: '%-d %b')
      return "#{I18n.t('common.today')} · #{day_month}" if date == Date.current
      return "#{I18n.t('common.yesterday')} · #{day_month}" if date == Date.current - 1

      "#{day_month} · #{t('history.index.day_group.weekdays')[date.wday]}"
    end
  end
end
