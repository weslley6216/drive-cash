module Goals
  class Shortfall
    def initialize(target:, achieved:)
      @target = target
      @achieved = achieved
    end

    def percent
      [(@achieved * 100 / @target).floor, 0].max
    end

    def amount
      @target - @achieved
    end

    def near?
      percent >= Goal::NEAR_MISS_PERCENT
    end
  end
end
