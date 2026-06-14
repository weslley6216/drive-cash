module Dashboard
  class InsightsService
    MAX_INSIGHTS = 3
    CATEGORIES_LIMIT = 7
    PLATFORMS_LIMIT = 5
    SEVERITY_ORDER = { 'critical' => 0, 'warning' => 1, 'info' => 2 }.freeze

    INSIGHT_RULES = [
      Insights::CategorySpike,
      Insights::BestDay,
      Insights::WorstPlatform,
      Insights::MarginDrop
    ].freeze

    def initialize(year:, month: nil, user: Current.user)
      @year = year
      @month = month
      @user = user
    end

    def call
      {
        metrics:        metrics,
        monthly_bars:   monthly_bars,
        categories:     categories,
        platforms:      platforms,
        insights:       insights,
        period_context: period_context
      }
    end

    private

    attr_reader :year, :month

    def current_stats
      @current_stats ||= StatsService.new(year: year, month: month, user: @user).metrics
    end

    def previous_stats
      @previous_stats ||= StatsService.new(
        year:          previous_year,
        month:         previous_month,
        through_month: ytd_cutoff,
        user:          @user
      ).metrics
    end

    def current_calculator
      @current_calculator ||= MetricsCalculator.from_stats(current_stats)
    end

    def previous_calculator
      @previous_calculator ||= MetricsCalculator.from_stats(previous_stats)
    end

    def ytd_cutoff
      return nil if month
      return nil if year != Date.current.year

      Date.current.month
    end

    def previous_year
      return year - 1 unless month

      month == 1 ? year - 1 : year
    end

    def previous_month
      return nil unless month

      month == 1 ? 12 : month - 1
    end

    def period_context
      if month
        {
          mode:                :monthly,
          previous_month_name: I18n.t('date.abbr_month_names')[previous_month],
          previous_year:       previous_year
        }
      else
        cutoff = ytd_cutoff
        {
          mode:              :annual,
          cutoff_month_name: cutoff ? I18n.t('date.abbr_month_names')[cutoff] : nil,
          previous_year:     previous_year
        }
      end
    end

    def metrics
      {
        per_day:    current_stats[:profit_per_day],
        per_trip:   current_calculator.per_trip,
        per_hour:   current_calculator.per_hour,
        margin:     current_calculator.margin,
        change_pct: {
          per_day:  PercentChange.between(current_stats[:profit_per_day], previous_stats[:profit_per_day]),
          per_trip: PercentChange.between(current_calculator.per_trip, previous_calculator.per_trip),
          per_hour: PercentChange.between(current_calculator.per_hour, previous_calculator.per_hour),
          margin:   PercentChange.between(current_calculator.margin, previous_calculator.margin)
        }
      }
    end

    def categories
      @categories ||= CategoryBreakdownService.new(year: year, month: month, limit: CATEGORIES_LIMIT, user: @user).call
    end

    def platforms
      @platforms ||= PlatformBreakdownService.new(year: year, month: month, limit: PLATFORMS_LIMIT, user: @user).call
    end

    def monthly_bars
      BarsBuilder.new(user: @user, year: year, month: month).call
    end

    def insight_context
      @insight_context ||= Insights::Context.new(
        user:           @user,
        year:           year,
        month:          month,
        previous_year:  previous_year,
        previous_month: previous_month,
        current_stats:  current_stats,
        previous_stats: previous_stats,
        categories:     categories,
        platforms:      platforms
      )
    end

    def insights
      INSIGHT_RULES.filter_map { |rule| rule.new(insight_context).call }
        .sort_by { |raw| SEVERITY_ORDER.fetch(raw[:severity], 99) }
        .first(MAX_INSIGHTS)
        .map { |raw| Insights::Presenters.present(raw) }
    end
  end
end
