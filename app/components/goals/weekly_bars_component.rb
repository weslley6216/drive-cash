module Goals
  class WeeklyBarsComponent < ApplicationComponent
    BAR_COLORS = {
      done: 'bg-emerald-500',
      today: 'bg-blue-600',
      future: 'bg-slate-200'
    }.freeze

    def initialize(days:, target:)
      @days = days
      @target = target
    end

    def view_template
      div(class: 'flex items-end justify-between gap-2 h-32') do
        @days.first(7).each { |day_data| render_bar(day_data) }
      end
    end

    private

    def render_bar(day_data)
      ratio = @target.to_f.positive? ? (day_data[:value].to_f / @target).clamp(0, 1) : 0
      height_pct = (ratio * 100).round
      state = day_data[:today] ? :today : day_data[:done] ? :done : :future

      div(class: 'flex flex-col items-center flex-1 gap-2') do
        div(class: 'w-full flex items-end justify-center h-24') do
          div(
            data: { day_bar: day_data[:date].iso8601 },
            class: "w-full rounded-t-md #{BAR_COLORS[state]}",
            style: "height: #{height_pct}%"
          )
        end
        span(class: 'text-[10px] uppercase font-medium text-slate-500') do
          plain I18n.l(day_data[:date], format: '%a').downcase[0, 3]
        end
      end
    end
  end
end
