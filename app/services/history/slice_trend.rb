module History
  class SliceTrend
    def initialize(slice:, user:, year:, month:)
      @slice = slice
      @user = user
      @year = year
      @month = month
    end

    def call
      return nil unless @slice.single_series? && @month.present?

      totals = monthly_totals
      months = window.map { |year, month| { year: year, month: month, total: totals[[year, month]] || 0 } }

      { kind: kind, months: months, change: change(months), in_progress: current_month? }
    end

    private

    def kind
      @slice.include_earnings? ? :earnings : :expenses
    end

    def window
      end_date = Date.new(@year, @month, 1)
      (0..5).map { |offset| start = end_date << (5 - offset); [start.year, start.month] }
    end

    def monthly_totals
      first_year, first_month = window.first
      last_year, last_month = window.last
      range = Date.new(first_year, first_month, 1)..Date.new(last_year, last_month, -1)

      base_scope.where(date: range).group(Arel.sql("DATE_TRUNC('month', date)")).sum(:amount)
        .each_with_object({}) { |(month_date, total), totals| totals[month_key(month_date)] = total.to_f }
    end

    def month_key(month_date)
      date = month_date.respond_to?(:to_date) ? month_date.to_date : Date.parse(month_date.to_s)
      [date.year, date.month]
    end

    def base_scope
      query = SliceQuery.new(@slice)
      kind == :earnings ? query.earnings(@user.earnings) : query.expenses(@user.expenses)
    end

    def change(months)
      return nil if months.length < 2

      Dashboard::PercentChange.between(months.last[:total], months[-2][:total])
    end

    def current_month?
      Date.current.year == @year && Date.current.month == @month
    end
  end
end
