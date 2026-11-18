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
      months = window.map { |year, month| { year: year, month: month, total: totals.dig([year, month], :total) || 0 } }

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

      SliceMonthlyTotals.new(slice: @slice, user: @user, period: range).call
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
