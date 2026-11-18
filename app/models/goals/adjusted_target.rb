module Goals
  class AdjustedTarget
    ROUNDING_STEP = 10

    def initialize(average:, target:)
      @average = average
      @target = target
    end

    def amount
      return nil if @average.nil?

      rounded = (@average / ROUNDING_STEP).floor * ROUNDING_STEP
      return nil if rounded <= 0
      return nil if rounded >= @target

      rounded
    end
  end
end
