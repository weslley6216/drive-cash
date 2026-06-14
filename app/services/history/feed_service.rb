module History
  class FeedService
    Filter = Data.define(:earnings, :expense_scope)

    FILTERS = {
      'all'      => Filter.new(earnings: true,  expense_scope: ->(user, year, month) { user.expenses.paid_in_period(year, month) }),
      'earnings' => Filter.new(earnings: true,  expense_scope: nil),
      'expenses' => Filter.new(earnings: false, expense_scope: ->(user, year, month) { user.expenses.paid_in_period(year, month) }),
      'unpaid'   => Filter.new(earnings: false, expense_scope: ->(user, year, month) { user.expenses.in_period(year, month).where(paid: false) })
    }.freeze

    def self.filter_names = FILTERS.keys

    def initialize(year: Date.current.year, month: nil, query: nil, filter: 'all', limit: 100, user: Current.user)
      @year = year
      @month = month
      @query = query
      @filter = filter
      @limit = limit
      @user = user
    end

    def call
      grouped = limited_items.group_by(&:date).sort_by { |date, _| date }.reverse

      {
        groups:  grouped.map { |date, day_items| build_group(date, day_items) },
        summary: build_summary
      }
    end

    private

    attr_reader :year, :month, :query, :filter, :limit

    def limited_items
      earnings = include_earnings? ? filtered_earnings.chronological.limit(limit).to_a : []
      expenses = include_expenses? ? filtered_expenses.chronological.limit(limit).to_a : []

      (earnings + expenses)
        .sort_by { |record| [record.date, record.created_at] }
        .reverse
        .first(limit)
    end

    def filtered_earnings
      search.earnings(@user.earnings.in_period(year, month))
    end

    def filtered_expenses
      base = filter_config.expense_scope.call(@user, year, month)
      search.expenses(base)
    end

    def filter_config
      @filter_config ||= FILTERS.fetch(filter, FILTERS.fetch('all'))
    end

    def search
      @search ||= RecordSearch.new(query)
    end

    def summary_earnings_scope
      @user.earnings.in_period(year, month)
    end

    def summary_expenses_scope
      @user.expenses.paid_in_period(year, month)
    end

    def build_summary
      earnings_total = summary_earnings_scope.sum(:amount)
      expenses_total = summary_expenses_scope.sum(:amount)

      {
        earnings: earnings_total,
        expenses: expenses_total,
        net: earnings_total - expenses_total
      }
    end

    def include_earnings?
      filter_config.earnings
    end

    def include_expenses?
      !filter_config.expense_scope.nil?
    end

    def build_group(date, day_items)
      day_earnings = day_items.select { |record| record.is_a?(Earning) }.sum(&:amount)
      day_expenses = day_items.select { |record| record.is_a?(Expense) }.sum(&:amount)

      {
        date: date,
        items: day_items.sort_by(&:created_at).reverse,
        earnings_total: day_earnings,
        expenses_total: day_expenses
      }
    end
  end
end
