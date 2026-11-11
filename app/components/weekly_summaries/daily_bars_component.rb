module WeeklySummaries
  class DailyBarsComponent < ApplicationComponent
    MAX_BAR_HEIGHT = 76

    def initialize(week:, daily_profits:, best_day_index:)
      @week = week
      @daily_profits = daily_profits
      @best_day_index = best_day_index
    end

    def view_template
      div(class: 'bg-white rounded-xl shadow-sm border border-slate-100 p-4') do
        h3(class: 'text-sm font-semibold text-slate-800 mb-3') { t('weekly_summaries.show.daily_title') }
        bars
        best_day_sentence
      end
    end

    private

    def bars
      div(class: 'flex items-end justify-between gap-2 h-[96px]') do
        dates.each_with_index { |date, index| bar(date, index) }
      end
    end

    def bar(date, index)
      value = @daily_profits[index]
      best = index == @best_day_index

      div(class: 'flex-1 flex flex-col items-center gap-1.5', data: { weekday: index }) do
        div(class: "w-full rounded-md #{bar_color(value, best)}", style: "height: #{bar_height(value)}px")
        span(class: "text-[10px] #{best ? 'font-bold text-blue-600' : 'text-slate-400'}") do
          plain I18n.t('date.abbr_day_names')[date.wday]
        end
      end
    end

    def bar_color(value, best)
      return 'bg-slate-100' unless value.positive?

      best ? 'bg-blue-600' : 'bg-blue-200'
    end

    def bar_height(value)
      return 4 unless value.positive?

      (value.to_f / best_value * MAX_BAR_HEIGHT).round(1)
    end

    def best_value
      @daily_profits[@best_day_index]
    end

    def best_day_sentence
      return if @best_day_index.nil?

      weekday_name = I18n.t('weekly_summaries.show.weekdays')[dates[@best_day_index].wday]

      p(class: 'text-xs text-slate-500 mt-3') do
        plain "#{t('weekly_summaries.show.best_day', day: weekday_name)} "
        strong(class: 'text-slate-700') { format_currency(best_value) }
        plain '.'
      end
    end

    def dates
      @dates ||= @week.to_a
    end
  end
end
