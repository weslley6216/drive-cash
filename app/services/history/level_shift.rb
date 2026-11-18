module History
  class LevelShift
    TOLERANCE = 0.01
    MIN_SHIFT = 0.02
    MIN_PRIOR_MONTHS = 2

    def initialize(months)
      @months = months.reject { |month| month[:total].zero? }
    end

    def call
      return nil if @months.empty?

      current_start = level_start(@months.size - 1)
      return nil if current_start < MIN_PRIOR_MONTHS

      previous_start = level_start(current_start - 1)
      return nil if current_start - previous_start < MIN_PRIOR_MONTHS

      build_shift(current_start)
    end

    private

    def level_start(end_index)
      start = end_index
      min = max = @months[end_index][:total]

      while start > 0
        candidate = @months[start - 1][:total]
        new_min = [min, candidate].min
        new_max = [max, candidate].max
        break if new_max - new_min > TOLERANCE * new_min

        min, max = new_min, new_max
        start -= 1
      end

      start
    end

    def build_shift(start)
      from = @months[start - 1][:total]
      to = @months[start][:total]
      change = Dashboard::PercentChange.between(to, from)
      return nil if change.abs < MIN_SHIFT * 100

      { year: @months[start][:year], month: @months[start][:month], from: from, to: to, change: change }
    end
  end
end
