module History
  class DayGroupComponent < ApplicationComponent
    include CardStyles

    def initialize(group:, context:)
      @group = group
      @context = context
    end

    def view_template
      @group[:gap] ? gap_day : logged_day
    end

    private

    def logged_day
      section(id: section_id) do
        header
        list
      end
    end

    def gap_day
      section do
        div(class: 'flex items-center justify-between mb-2 px-1') do
          p(class: 'text-xs font-bold text-slate-500 uppercase tracking-wider') { date_label }
          p(class: 'text-xs font-medium text-slate-400') { t('history.index.gap_day.no_records') }
        end
        div(id: section_id, class: 'rounded-xl border border-dashed border-slate-300 bg-white/70 px-4 py-3.5 flex items-center gap-3') do
          div(class: 'w-10 h-10 rounded-lg bg-slate-100 text-slate-500 flex items-center justify-center flex-shrink-0') do
            render PhlexIcons::Lucide::Calendar.new(class: 'w-[18px] h-[18px]')
          end
          div(class: 'flex-1 min-w-0') do
            p(class: 'text-sm font-semibold text-slate-700') { t('history.index.gap_day.title') }
            p(class: 'text-xs text-slate-500 leading-snug') { t('history.index.gap_day.hint') }
          end
          link_to(t('history.index.gap_day.log'), new_record_path(date: @group[:date]),
                  data:  { turbo_frame: '_top' },
                  class: 'inline-flex items-center px-3 h-9 rounded-lg bg-blue-600 text-white text-xs font-semibold flex-shrink-0')
        end
      end
    end

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
