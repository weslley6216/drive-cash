module Goals
  class NextTarget
    GROWTH = BigDecimal('1.05')
    ROUNDING_STEP = 100

    def initialize(result:)
      @result = result
    end

    def amount
      (@result * GROWTH / ROUNDING_STEP).ceil * ROUNDING_STEP
    end
  end
end
