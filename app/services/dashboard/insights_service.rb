module Dashboard
  class InsightsService
    include Formatting

    HOURS_PER_DAY = 8
    CATEGORIES_LIMIT = 7
    PLATFORMS_LIMIT = 5
    MAX_INSIGHTS = 3
    CATEGORY_SPIKE_THRESHOLD = 10.0
    MARGIN_DROP_THRESHOLD = 5.0
    SEVERITY_ORDER = { 'critical' => 0, 'warning' => 1, 'info' => 2 }.freeze

    def initialize(year:, month: nil, user: Current.user)
      @year = year
      @month = month
      @user = user
    end

    def call
      {
        metrics: metrics,
        monthly_bars: monthly_bars,
        categories: categories,
        platforms: platforms,
        insights: insights,
        period_context: period_context
      }
    end

    private

    attr_reader :year, :month

    def current_stats
      @current_stats ||= Dashboard::StatsService.new(year: year, month: month, user: @user).call
    end

    def previous_stats
      @previous_stats ||= Dashboard::StatsService.new(
        year: previous_year,
        month: previous_month,
        through_month: ytd_cutoff,
        user: @user
      ).call
    end

    def ytd_cutoff
      return nil if month
      return nil if year != Date.current.year

      Date.current.month
    end

    def period_context
      if month
        {
          mode: :monthly,
          previous_month_name: I18n.t('date.abbr_month_names')[month],
          previous_year: previous_year
        }
      else
        cutoff = ytd_cutoff
        cutoff_name = cutoff ? I18n.t('date.abbr_month_names')[cutoff] : nil
        {
          mode: :annual,
          cutoff_month_name: cutoff_name,
          previous_year: previous_year
        }
      end
    end

    def previous_year
      year - 1
    end

    def previous_month
      month
    end

    def metrics
      {
        per_day: current_stats[:profit_per_day],
        per_trip: per_trip(current_stats),
        per_hour: per_hour(current_stats),
        margin: margin(current_stats),
        change_pct: {
          per_day:  pct_change(current_stats[:profit_per_day], previous_stats[:profit_per_day]),
          per_trip: pct_change(per_trip(current_stats), per_trip(previous_stats)),
          per_hour: pct_change(per_hour(current_stats), per_hour(previous_stats)),
          margin:   pct_change(margin(current_stats), margin(previous_stats))
        }
      }
    end

    def per_trip(stats)
      trips = stats[:trips].to_i
      return 0 if trips.zero?

      (stats[:profit].to_f / trips).round(2)
    end

    def per_hour(stats)
      days = stats[:days].to_i
      return 0 if days.zero?

      (stats[:profit].to_f / (days * HOURS_PER_DAY)).round(2)
    end

    def margin(stats)
      earnings = stats[:earnings].to_f
      return 0 if earnings.zero?

      ((stats[:profit].to_f / earnings) * 100).round(1)
    end

    def pct_change(current_value, previous_value)
      current_float  = current_value.to_f
      previous_float = previous_value.to_f
      return nil if previous_float.zero?

      ((current_float - previous_float) / previous_float.abs * 100).round(1)
    end

    def categories
      Dashboard::CategoryBreakdownService.new(year: year, month: month, limit: CATEGORIES_LIMIT, user: @user).call
    end

    def platforms
      Dashboard::PlatformBreakdownService.new(year: year, month: month, limit: PLATFORMS_LIMIT, user: @user).call
    end

    def insights
      candidates = [category_spike_insight, best_day_insight, worst_platform_insight, margin_drop_insight].compact
      candidates.sort_by { |insight| SEVERITY_ORDER.fetch(insight[:severity], 99) }.first(MAX_INSIGHTS)
    end

    def category_spike_insight
      current_top = categories.first
      previous_top_amount = previous_amount_for_category(current_top&.dig(:id))
      return nil if current_top.nil? || previous_top_amount.zero?

      pct = ((current_top[:amount].to_f - previous_top_amount) / previous_top_amount * 100).round(1)
      return nil if pct <= CATEGORY_SPIKE_THRESHOLD

      {
        type: 'category_spike',
        severity: 'warning',
        title: I18n.t('analysis.show_view.insights.category_spike.title', category: current_top[:label], pct: pct),
        description: category_spike_description(current_top, pct)
      }
    end

    def category_spike_description(current_top, pct)
      if month
        I18n.t('analysis.show_view.insights.category_spike.description_monthly',
               category: current_top[:label], pct: pct,
               value: format_currency(current_top[:amount]),
               period: I18n.t('date.month_names')[month],
               previous_year: previous_year)
      else
        I18n.t('analysis.show_view.insights.category_spike.description_annual',
               category: current_top[:label], pct: pct,
               value: format_currency(current_top[:amount]),
               previous_year: previous_year)
      end
    end

    def best_day_insight
      return nil unless month

      best = @user.earnings.for_year(year).for_month(month)
                  .group(:date).sum(:amount).max_by { |_date, amount| amount }
      return nil if best.nil?

      best_date, best_amount = best
      {
        type: 'best_day',
        severity: 'info',
        title: I18n.t('analysis.show_view.insights.best_day.title', value: format_currency(best_amount)),
        description: I18n.t('analysis.show_view.insights.best_day.description',
                            date: I18n.l(best_date, format: :default))
      }
    end

    def worst_platform_insight
      return nil if platforms.size < 2

      worst = platforms.last
      trips = worst[:trips_count].to_i
      return nil if trips.zero?

      per_trip_value = (worst[:amount].to_f / trips).round(2)
      {
        type: 'worst_platform',
        severity: 'info',
        title: I18n.t('analysis.show_view.insights.worst_platform.title', platform: worst[:label]),
        description: I18n.t('analysis.show_view.insights.worst_platform.description',
                            platform: worst[:label], value: format_currency(per_trip_value))
      }
    end

    def margin_drop_insight
      current_margin = margin(current_stats)
      previous_margin = margin(previous_stats)
      pp_diff = (current_margin - previous_margin).round(1)
      return nil if previous_margin.zero? || pp_diff >= -MARGIN_DROP_THRESHOLD

      {
        type: 'margin_drop',
        severity: 'critical',
        title: I18n.t('analysis.show_view.insights.margin_drop.title', pp: pp_diff.abs),
        description: I18n.t('analysis.show_view.insights.margin_drop.description', value: current_margin)
      }
    end

    def previous_amount_for_category(category_id)
      return 0 unless category_id

      @user.expenses.for_year(previous_year).paid_only
           .then { |relation| previous_month ? relation.for_month(previous_month) : relation }
           .where(category: category_id).sum(:amount).to_f
    end

    def monthly_bars
      month ? daily_bars : annual_month_bars
    end

    def annual_month_bars
      earnings_by = @user.earnings.for_year(year)
                         .group(Arel.sql('EXTRACT(MONTH FROM date)::int'))
                         .sum(:amount)
      expenses_by = @user.expenses.for_year(year).paid_only
                         .group(Arel.sql('EXTRACT(MONTH FROM date)::int'))
                         .sum(:amount)

      has_any_data = (earnings_by.keys + expenses_by.keys).any?
      return [] unless has_any_data

      (1..12).map do |month_number|
        {
          unit: :month,
          key: month_number,
          label: I18n.t('date.abbr_month_names')[month_number].capitalize,
          earnings: earnings_by[month_number].to_f,
          expenses: expenses_by[month_number].to_f,
          empty: earnings_by[month_number].nil? && expenses_by[month_number].nil?
        }
      end
    end

    def daily_bars
      earnings_by = @user.earnings.for_year(year).for_month(month)
                         .group(Arel.sql('EXTRACT(DAY FROM date)::int'))
                         .sum(:amount)
      expenses_by = @user.expenses.for_year(year).paid_only.for_month(month)
                         .group(Arel.sql('EXTRACT(DAY FROM date)::int'))
                         .sum(:amount)

      days = (earnings_by.keys + expenses_by.keys).uniq.sort
      days.map do |day|
        {
          unit: :day,
          key: day,
          label: day.to_s,
          earnings: earnings_by[day].to_f,
          expenses: expenses_by[day].to_f,
          empty: false
        }
      end
    end
  end
end
