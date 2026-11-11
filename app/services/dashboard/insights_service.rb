module Dashboard
  class InsightsService
    CATEGORIES_LIMIT = 7
    PLATFORMS_LIMIT = 5

    INSIGHT_RULES = [
      Insights::CategoryShare
    ].freeze

    def initialize(year:, month: nil, user: Current.user)
      @year = year
      @month = month
      @user = user
    end

    def call
      {
        metrics:         metrics,
        monthly_bars:    monthly_bars,
        categories:      categories,
        platforms:       platforms,
        platforms_total: platforms_total,
        insights:        insights
      }
    end

    private

    attr_reader :year, :month

    def current_stats
      @current_stats ||= StatsService.new(year: year, month: month, user: @user).metrics
    end

    def current_calculator
      @current_calculator ||= MetricsCalculator.from_stats(current_stats)
    end

    def current_km
      @current_km ||= KmDriven.new(user: @user, year: year, month: month).call
    end

    def metrics
      {
        earnings: current_stats[:earnings],
        expenses: current_stats[:expenses],
        per_day:  current_stats[:profit_per_day],
        per_trip: current_calculator.per_trip,
        per_km:   current_calculator.per_km(current_km),
        margin:   current_calculator.margin,
        series:   MetricsSeries.new(user: @user, year: year, month: month).call
      }
    end

    def categories
      @categories ||= CategoryBreakdownService.new(year: year, month: month, limit: CATEGORIES_LIMIT, user: @user).call
    end

    def platform_breakdown
      @platform_breakdown ||= PlatformBreakdownService.new(year: year, month: month, limit: PLATFORMS_LIMIT, user: @user)
    end

    def platforms
      @platforms ||= platform_breakdown.call
    end

    def platforms_total
      platform_breakdown.total
    end

    def monthly_bars
      BarsBuilder.new(user: @user, year: year, month: month).call
    end

    def insight_context
      @insight_context ||= Insights::Context.new(
        user:          @user,
        year:          year,
        month:         month,
        current_stats: current_stats,
        categories:    categories,
        platforms:     platforms
      )
    end

    def insights
      INSIGHT_RULES.filter_map { |rule| rule.new(insight_context).call }
        .map { |raw| Insights::Presenters.present(raw) }
    end
  end
end
