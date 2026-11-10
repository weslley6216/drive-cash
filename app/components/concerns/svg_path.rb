module SvgPath
  def line_path(points)
    points.each_with_index.map { |(x, y), index| "#{index.zero? ? 'M' : 'L'}#{x},#{y}" }.join(' ')
  end

  def area_path(points, height)
    return '' if points.empty?

    line = line_path(points)
    last_x = points.last.first
    "#{line} L#{last_x},#{height} L0,#{height} Z"
  end
end
