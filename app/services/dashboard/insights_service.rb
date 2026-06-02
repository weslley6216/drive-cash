module Dashboard
  class InsightsService
    def initialize(year:, month: nil)
      @year = year
      @month = month
    end

    def call
      { metrics: {}, monthly_bars: [], categories: [], platforms: [], insights: [] }
    end
  end
end
