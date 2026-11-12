module Goals
  class WeeklyBarsComponent < ApplicationComponent
    TARGET_SHARE_PER_BAR = 5

    def initialize(days:, target:)
      @days = days
      @target = target
    end

    def view_template
      div(class: 'grid grid-cols-7 gap-1.5 lg:gap-2 lg:mt-4') do
        @days.first(7).each { |day_data| render_bar(day_data) }
      end
    end

    private

    def render_bar(day_data)
      state = bar_state(day_data)

      div(class: 'flex flex-col items-center gap-1') do
        div(class: 'w-full flex items-end justify-center h-[60px] lg:h-[70px]') do
          div(
            data:  { day_bar: day_data[:date].iso8601 },
            class: bar_classes(state),
            style: "height: #{height_percent(day_data[:value])}%"
          )
        end
        span(class: "lg:hidden text-[10px] font-medium #{label_color(state)}") do
          plain I18n.l(day_data[:date], format: '%a').upcase[0]
        end
        span(class: "hidden lg:block text-[10px] font-medium #{label_color(state)}") do
          plain I18n.l(day_data[:date], format: '%a').capitalize.first(3)
        end
      end
    end

    def height_percent(value)
      bar_reference = @target.to_f / TARGET_SHARE_PER_BAR
      return 0 unless bar_reference.positive?

      ((value.to_f / bar_reference).clamp(0, 1) * 100).round
    end

    def bar_state(day_data)
      return :today if day_data[:today]
      return :done if day_data[:done]

      :future
    end

    def bar_classes(state)
      base = 'w-full rounded min-h-2'
      case state
      when :done then "#{base} bg-emerald-500"
      when :today then "#{base} bg-blue-200 border-2 border-blue-500 border-dashed"
      when :future then "#{base} bg-slate-100"
      end
    end

    def label_color(state)
      state == :today ? 'text-blue-600' : 'text-slate-400'
    end
  end
end
