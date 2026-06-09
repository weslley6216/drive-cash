module Goals
  class ProgressRingComponent < ApplicationComponent
    def initialize(percent:, size: 120, color: '#2563eb', stroke: 10)
      @percent = percent.to_f.clamp(0, 100)
      @size = size
      @color = color
      @stroke = stroke
    end

    def view_template
      radius = (@size - @stroke) / 2.0
      circumference = (2 * Math::PI * radius).round(4)
      offset = (circumference - (@percent / 100.0) * circumference).round(4)

      div(class: 'relative flex-shrink-0', style: "width: #{@size}px; height: #{@size}px") do
        svg(width: @size, height: @size, class: '-rotate-90', viewBox: "0 0 #{@size} #{@size}") do |s|
          s.circle(cx: @size / 2, cy: @size / 2, r: radius, fill: 'none', stroke: '#f1f5f9', 'stroke-width': @stroke)
          s.circle(
            cx: @size / 2, cy: @size / 2, r: radius, fill: 'none',
            stroke: @color, 'stroke-width': @stroke, 'stroke-linecap': 'round',
            'stroke-dasharray': circumference, 'stroke-dashoffset': offset
          )
        end
        div(class: 'absolute inset-0 flex flex-col items-center justify-center') do
          div(class: 'flex items-end') do
            span(class: 'text-2xl font-bold text-slate-800') { plain @percent.round.to_s }
            span(class: 'text-sm font-medium text-slate-500') { '%' }
          end
        end
      end
    end
  end
end
