module Dashboard
  class YearLedger
    EarningDay = Data.define(:amount, :trips)

    def initialize(user:, year:)
      @user = user
      @year = year.to_i
    end

    def earning_days(month = nil)
      filter_by_month(earnings_by_day, month)
    end

    def earned_in(month = nil)
      earning_days(month).values.sum(0) { |earning_day| earning_day.amount }
    end

    def earned_on(date)
      earnings_by_day.fetch(date, EarningDay.new(amount: 0, trips: 0)).amount
    end

    def spent_in(month = nil)
      filter_by_month(spent_by_day, month).values.sum(0)
    end

    def spent_on(date)
      spent_by_day.fetch(date, 0)
    end

    def spent_by_category(month = nil)
      expenses_by_day_and_category
        .select { |(date, _category), _amount| month.nil? || date.month == month }
        .each_with_object(Hash.new(0)) { |((_date, category), amount), totals| totals[category] += amount }
    end

    def daily_totals
      Goals::DailyTotals.new(
        earnings_by_day.transform_values(&:amount),
        spent_by_day,
        range: Date.new(@year, 1, 1)..Date.new(@year, 12, 31)
      )
    end

    private

    def filter_by_month(days, month)
      return days if month.nil?

      days.select { |date, _value| date.month == month }
    end

    def earnings_by_day
      @earnings_by_day ||= @user.earnings.for_year(@year)
        .group(:date)
        .pluck(:date, Arel.sql('SUM(amount)'), Arel.sql('SUM(trips_count)'))
        .each_with_object({}) { |(date, amount, trips), days| days[date] = EarningDay.new(amount: amount, trips: trips) }
    end

    def expenses_by_day_and_category
      @expenses_by_day_and_category ||= @user.expenses.paid_in_period(@year).group(:date, :category).sum(:amount)
    end

    def spent_by_day
      @spent_by_day ||= expenses_by_day_and_category
        .each_with_object(Hash.new(0)) { |((date, _category), amount), days| days[date] += amount }
    end
  end
end
