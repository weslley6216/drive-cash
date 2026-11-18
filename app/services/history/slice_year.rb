module History
  class SliceYear
    def initialize(slice:, user:, query: nil)
      @slice = slice
      @user = user
      @query = query
    end

    def call
      return nil unless @slice.twelve_months?

      breakdown = MonthlyBreakdown.new(window: window, totals: monthly_totals.call).call

      breakdown.merge(kind: kind, series: series, count: breakdown[:months].sum { |month| month[:count] },
                      rows: attach_records(breakdown[:rows]))
    end

    private

    def window
      first_month = Date.current.beginning_of_month << 11
      (0..11).map { |offset| month = first_month >> offset; [month.year, month.month] }
    end

    def period
      first_year, first_month = window.first
      Date.new(first_year, first_month, 1)..Date.current.end_of_month
    end

    def monthly_totals
      @monthly_totals ||= SliceMonthlyTotals.new(slice: @slice, user: @user, period: period, query: @query)
    end

    def kind
      @slice.include_earnings? ? :earnings : :expenses
    end

    def series
      @slice.platforms.first || @slice.categories.first
    end

    def attach_records(rows)
      records = latest_records_by_month
      rows.map { |row| row.merge(record: records[[row[:year], row[:month]]]) }
    end

    def latest_records_by_month
      monthly_totals.scope
        .select("DISTINCT ON (DATE_TRUNC('month', date)) *")
        .order(Arel.sql("DATE_TRUNC('month', date), date DESC, created_at DESC"))
        .index_by { |record| [record.date.year, record.date.month] }
    end
  end
end
