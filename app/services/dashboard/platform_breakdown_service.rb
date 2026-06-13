module Dashboard
  class PlatformBreakdownService
    def initialize(year:, month: nil, limit: 5, user: Current.user)
      @year = year
      @month = month
      @limit = limit
      @user = user
    end

    def call
      total = scope.sum(:amount).to_f
      return [] if total.zero?

      aggregates = scope.group(:platform).pluck(
        :platform,
        Arel.sql('SUM(amount)'),
        Arel.sql('SUM(trips_count)')
      )

      aggregates
        .sort_by { |_platform, amount, _trips| -amount }
        .first(@limit)
        .map { |platform, amount, trips| build_row(platform, amount, total, trips.to_i) }
    end

    private

    attr_reader :year, :month, :limit

    def scope
      @scope ||= @user.earnings.in_period(year, month)
    end

    def build_row(platform, amount, total, trips)
      {
        id: platform,
        label: I18n.t("activerecord.attributes.earning.platforms.#{platform}"),
        amount: amount,
        percent: (amount.to_f / total * 100).round(1),
        trips_count: trips
      }
    end
  end
end
