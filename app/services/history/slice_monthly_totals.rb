module History
  class SliceMonthlyTotals
    def initialize(slice:, user:, period:, query: nil)
      @slice = slice
      @user = user
      @period = period
      @query = query
    end

    def call
      scope.group(Arel.sql("DATE_TRUNC('month', date)"))
        .pluck(Arel.sql("DATE_TRUNC('month', date)"), Arel.sql('SUM(amount)'), Arel.sql('COUNT(*)'))
        .each_with_object({}) { |(month_date, total, count), totals| totals[month_key(month_date)] = { total: total.to_f, count: count } }
    end

    def scope
      search = RecordSearch.new(@query)
      base = @slice.include_earnings? ? search.earnings(slice_query.earnings(@user.earnings)) : search.expenses(slice_query.expenses(@user.expenses))
      base.where(date: @period)
    end

    private

    def slice_query
      @slice_query ||= SliceQuery.new(@slice)
    end

    def month_key(month_date)
      date = month_date.respond_to?(:to_date) ? month_date.to_date : Date.parse(month_date.to_s)
      [date.year, date.month]
    end
  end
end
