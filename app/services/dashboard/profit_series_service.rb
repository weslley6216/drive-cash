module Dashboard
  class ProfitSeriesService
    def initialize(year:, month: nil, user: Current.user, ledger: nil)
      @year = year
      @month = month
      @user = user
      @ledger = ledger || YearLedger.new(user: user, year: year)
    end

    def monthly
      @monthly ||= (1..12).map { |month_number| (ledger.earned_in(month_number) - ledger.spent_in(month_number)).to_f.round(2) }
    end

    def daily
      return nil unless month

      (1..last_plotted_day).map { |day| (ledger.earned_on(day_date(day)) - ledger.spent_on(day_date(day))).to_f.round(2) }
    end

    private

    attr_reader :year, :month, :ledger

    def day_date(day)
      Date.new(year.to_i, month.to_i, day)
    end

    def last_plotted_day
      today = Date.current
      return today.day if today.year == year.to_i && today.month == month.to_i

      Date.new(year.to_i, month.to_i, -1).day
    end
  end
end
