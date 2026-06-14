module Dashboard
  class PlatformBreakdownService < BreakdownService
    private

    def default_limit = 5

    def aggregates
      user.earnings.in_period(year, month)
          .group(:platform)
          .pluck(:platform, Arel.sql('SUM(amount)'), Arel.sql('SUM(trips_count)'))
          .map { |platform, amount, trips| { id: platform, amount: amount, trips: trips.to_i } }
    end

    def build_row(row)
      {
        id: row[:id],
        label: I18n.t("activerecord.attributes.earning.platforms.#{row[:id]}"),
        amount: row[:amount],
        percent: percent(row[:amount]),
        trips_count: row[:trips]
      }
    end
  end
end
