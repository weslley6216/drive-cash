module Dashboard
  class BreakdownService
    def initialize(year:, month: nil, limit: nil, user: Current.user)
      @year = year
      @month = month
      @limit = limit || default_limit
      @user = user
    end

    def call
      return [] if total.zero?

      rows.sort_by { |row| -row[:amount] }
        .first(@limit)
        .map { |row| build_row(row) }
    end

    private

    attr_reader :year, :month, :user

    def rows
      @rows ||= aggregates
    end

    def total
      @total ||= rows.sum { |row| row[:amount] }.to_f
    end

    def percent(amount)
      (amount.to_f / total * 100).round(1)
    end
  end
end
