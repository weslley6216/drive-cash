class SparklineComponent < ApplicationComponent
  include SvgPath

  VIEWBOX_WIDTH = 100

  def initialize(values:, color:, height:, height_class:, fill: true)
    @values = values
    @color = color
    @height = height
    @height_class = height_class
    @fill = fill
  end

  def view_template
    svg(viewBox: "0 0 #{VIEWBOX_WIDTH} #{@height}", preserveAspectRatio: 'none',
        class: "w-full overflow-visible #{@height_class}") do |svg|
      svg.path(d: area_path(points, @height), fill: @color, 'fill-opacity': '0.12') if @fill
      svg.path(d: line_path(points), fill: 'none', stroke: @color, 'stroke-width': '2',
               'stroke-linecap': 'round', 'stroke-linejoin': 'round', 'vector-effect': 'non-scaling-stroke')
    end
  end

  private

  def points
    min = [@values.min, 0].min
    max = [@values.max, 1].max
    range = max - min

    @values.each_with_index.map do |value, index|
      x = (index * VIEWBOX_WIDTH.to_f / (@values.size - 1)).round(2)
      y = (@height - ((value.to_f - min) / range) * (@height - 4) - 2).round(2)
      [x, y]
    end
  end
end
