module WeeklySummaries
  class DailyBarsComponent < ApplicationComponent
    include BarTooltip

    def initialize(week:, days:, best_day_index:, empty_days: [], blank_week: false)
      @week = week
      @days = days
      @best_day_index = best_day_index
      @empty_days = empty_days
      @blank_week = blank_week
    end

    def view_template
      div(class: 'bg-white rounded-xl shadow-sm border border-slate-100 p-4') do
        h3(class: 'text-sm font-semibold text-slate-800 mb-3') { t('weekly_summaries.show.daily_title') }
        bars
        day_sentence
      end
    end

    private

    def bars
      div(class: 'relative', data: { controller: 'bar-tooltip', bar_tooltip_placement_value: 'above-or-side',
                                     bar_tooltip_dismiss_outside_value: 'true', bar_tooltip_dim_opacity_value: '0.4',
                                     bar_tooltip_negative_class: 'text-red-400', bar_tooltip_positive_class: 'text-white' }) do
        tooltip_node
        div(class: 'flex items-end justify-between gap-2 h-[96px] lg:h-[150px]') do
          @days.each_with_index { |day, index| bar(day, index) }
        end
      end
    end

    def bar(day, index)
      day.future ? future_bar(day, index) : past_bar(day, index)
    end

    def past_bar(day, index)
      best = index == @best_day_index

      div(class: 'flex-1 h-full flex flex-col items-center gap-1.5 rounded-md outline-none cursor-pointer',
          role: 'button', tabindex: '0', aria_label: aria_label(day), data: column_data(day, index)) do
        bar_fill(day.profit, best)
        span(class: "text-[10px] #{best ? 'font-bold text-blue-600' : 'text-slate-400'}") do
          plain I18n.t('date.abbr_day_names')[day.date.wday]
        end
      end
    end

    def future_bar(day, index)
      div(class: 'flex-1 h-full flex flex-col items-center gap-1.5 rounded-md outline-none',
          aria_hidden: 'true', data: { weekday: index }) do
        bar_fill(day.profit, false)
        span(class: "text-[10px] #{index == @best_day_index ? 'font-bold text-blue-600' : 'text-slate-300'}") do
          plain I18n.t('date.abbr_day_names')[day.date.wday]
        end
      end
    end

    def bar_fill(value, best)
      div(class: 'w-full flex-1 flex items-end') do
        div(class: "w-full rounded-md #{bar_color(value, best)}", style: "height: #{bar_height(value)}",
            data: { bar_tooltip_target: 'fill' })
      end
    end

    def column_data(day, index)
      {
        weekday:            index,
        bar_tooltip_target: 'column',
        index:              index,
        label_text:         label_text(day.date),
        muted:              day.empty.to_s,
        negative:           day.profit.negative?.to_s,
        net:                format_currency(day.profit),
        earnings:           format_currency(day.earnings),
        expenses:           format_currency(day.expenses),
        trips:              day.trips,
        action:             COLUMN_ACTIONS
      }
    end

    def label_text(date)
      t('weekly_summaries.show.tooltip.day_label', weekday: I18n.t('date.abbr_day_names')[date.wday],
                                                    day: date.strftime('%d'), month: I18n.t('date.abbr_month_names')[date.month])
    end

    def aria_label(day)
      return "#{upcase_first(label_text(day.date))}: #{t('weekly_summaries.show.tooltip.no_data')}" if day.empty

      t('weekly_summaries.show.tooltip.aria', label: upcase_first(label_text(day.date)), net: format_currency(day.profit),
                                              earnings: format_currency(day.earnings), expenses: format_currency(day.expenses),
                                              trips: t('weekly_summaries.show.tooltip.aria_trips', count: day.trips))
    end

    def tooltip_node
      div(class: 'absolute z-20 pointer-events-none hidden', data: { bar_tooltip_target: 'tooltip' }) do
        div(class: 'relative bg-slate-900 text-white rounded-lg px-3 py-2 shadow-xl whitespace-nowrap') do
          p(class: 'text-[10px] font-semibold text-slate-400 mb-1 uppercase tracking-wide', data: { bar_tooltip_target: 'label' })
          p(class: 'text-xs text-slate-400 hidden', data: { bar_tooltip_target: 'noData' }) { plain t('weekly_summaries.show.tooltip.no_data') }
          div(class: 'min-w-[126px]', data: { bar_tooltip_target: 'values' }) do
            p(class: 'text-base font-bold tabular-nums text-white', data: { bar_tooltip_target: 'field', field: 'net', signed: 'true' })
            p(class: 'text-[10px] text-slate-400 mb-1.5') { plain t('weekly_summaries.show.tooltip.net_caption') }
            div(class: 'space-y-1 pt-1.5 border-t border-white/10') do
              tooltip_dot_row('bg-emerald-400', t('weekly_summaries.show.tooltip.earnings'), 'earnings')
              tooltip_dot_row('bg-red-400', t('weekly_summaries.show.tooltip.expenses'), 'expenses')
              tooltip_icon_row(t('weekly_summaries.show.tooltip.trips'), 'trips')
            end
          end
          div(class: 'absolute w-2 h-2 bg-slate-900', data: { bar_tooltip_target: 'arrow' })
        end
      end
    end

    def tooltip_dot_row(dot_class, label, field)
      div(class: 'flex items-center gap-2 text-xs') do
        span(class: 'w-3 flex justify-center') { span(class: "w-1.5 h-1.5 rounded-full #{dot_class}") }
        tooltip_row_tail(label, field)
      end
    end

    def tooltip_icon_row(label, field)
      div(class: 'flex items-center gap-2 text-xs') do
        render PhlexIcons::Lucide::Route.new(class: 'w-3 h-3 text-slate-400')
        tooltip_row_tail(label, field)
      end
    end

    def tooltip_row_tail(label, field)
      span(class: 'text-slate-300') { plain label }
      span(class: 'font-semibold tabular-nums ml-auto pl-3', data: { bar_tooltip_target: 'field', field: field })
    end

    def bar_color(value, best)
      return 'bg-slate-100' unless value.positive?

      best ? 'bg-blue-600' : 'bg-blue-200'
    end

    def bar_height(value)
      return '4px' unless value.positive?

      "#{(value.to_f / best_value * 100).round(1)}%"
    end

    def best_value
      @days[@best_day_index].profit
    end

    def day_sentence
      return blank_week_sentence if @blank_week
      return if @best_day_index.nil? && @empty_days.empty?

      p(class: 'text-xs text-slate-500 mt-3') do
        best_day_sentence
        empty_days_sentence
      end
    end

    def blank_week_sentence
      p(class: 'text-xs text-slate-500 mt-3') { plain t('weekly_summaries.show.blank_week') }
    end

    def best_day_sentence
      return if @best_day_index.nil?

      weekday_name = I18n.t('weekly_summaries.show.weekdays')[dates[@best_day_index].wday]

      plain "#{t('weekly_summaries.show.best_day', day: weekday_name)} "
      strong(class: 'text-slate-700') { format_currency(best_value) }
      plain '. '
    end

    def empty_days_sentence
      return if @empty_days.empty?

      names = @empty_days.map { |date| I18n.t('weekly_summaries.show.weekdays')[date.wday].downcase }.to_sentence

      plain t('weekly_summaries.show.empty_days', days: upcase_first(names))
    end

    def upcase_first(text)
      "#{text[0].upcase}#{text[1..]}"
    end

    def dates
      @dates ||= @days.map(&:date)
    end
  end
end
