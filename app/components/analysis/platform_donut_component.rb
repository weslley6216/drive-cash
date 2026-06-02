module Analysis
  class PlatformDonutComponent < ApplicationComponent
    DEFAULT_SIZE = 120
    STROKE_WIDTH = 14

    def initialize(platforms:, total:, size: DEFAULT_SIZE)
      @platforms = platforms
      @total = total.to_f
      @size = size
    end

    def view_template
      section(class: 'bg-white rounded-xl shadow-sm border border-slate-100 p-4') do
        h3(class: 'text-sm font-semibold text-slate-800 mb-1') { I18n.t('analysis.show_view.platforms.title') }
        p(class: 'text-xs text-slate-500 mb-3') do
          I18n.t('analysis.show_view.platforms.total_year', value: format_currency(@total))
        end
        @platforms.empty? ? empty_state : body
      end
    end

    private

    def body
      div(class: 'flex items-center gap-4') do
        div(class: 'relative shrink-0', style: "width: #{@size}px; height: #{@size}px") do
          donut
          center_label
        end
        legend
      end
    end

    def donut
      radius = (@size / 2.0) - (STROKE_WIDTH / 2.0)
      circumference = 2 * Math::PI * radius
      offset = 0

      svg(width: @size, height: @size, viewBox: "0 0 #{@size} #{@size}", class: '-rotate-90') do |svg_el|
        @platforms.each do |platform|
          seg_len = (platform[:amount].to_f / @total) * circumference
          svg_el.circle(
            cx: @size / 2, cy: @size / 2, r: radius,
            fill: 'none',
            stroke: platform[:color],
            stroke_width: STROKE_WIDTH,
            stroke_dasharray: "#{seg_len} #{circumference - seg_len}",
            stroke_dashoffset: -offset
          )
          offset += seg_len
        end
      end
    end

    def center_label
      div(class: 'absolute inset-0 flex flex-col items-center justify-center pointer-events-none') do
        span(class: 'text-[10px] text-slate-500') { I18n.t('analysis.show_view.platforms.total_label') }
        span(class: 'text-sm font-bold text-slate-800') do
          helpers.number_to_currency(@total.round, unit: 'R$ ', format: '%u%n', separator: ',', delimiter: '.', precision: 0)
        end
      end
    end

    def legend
      ul(class: 'flex-1 space-y-2') do
        @platforms.each { |platform| legend_row(platform) }
      end
    end

    def legend_row(platform)
      li(class: 'flex items-center gap-2') do
        span(class: 'w-2.5 h-2.5 rounded-sm shrink-0', style: "background-color: #{platform[:color]}")
        span(class: 'text-sm text-slate-700 flex-1 truncate') { platform[:label] }
        span(class: 'text-sm font-semibold text-slate-800 whitespace-nowrap') { "#{platform[:percent]}%" }
      end
    end

    def empty_state
      p(class: 'text-sm text-slate-400 text-center py-6') { I18n.t('analysis.show_view.platforms.empty') }
    end
  end
end
