module History
  class FeedService
    FILTERS = %w[all earnings expenses unpaid].freeze

    def initialize(year: Date.current.year, month: nil, query: nil, filter: 'all', limit: 100, user: Current.user)
      @year = year
      @month = month
      @query = query
      @filter = filter
      @limit = limit
      @user = user
    end

    def call
      all_items = full_scope
      limited   = all_items.first(limit)
      grouped   = limited.group_by(&:date).sort_by { |date, _| date }.reverse

      {
        groups:  grouped.map { |date, day_items| build_group(date, day_items) },
        summary: build_summary(period_items)
      }
    end

    private

    attr_reader :year, :month, :query, :filter, :limit

    def period_items
      earnings = @user.earnings.for_year(year)
      earnings = earnings.for_month(month) if month
      expenses = @user.expenses.paid_only.for_year(year)
      expenses = expenses.for_month(month) if month
      earnings.to_a + expenses.to_a
    end

    def full_scope
      base = []
      base += filtered_earnings.to_a if include_earnings?
      base += filtered_expenses.to_a if include_expenses?
      base.sort_by { |record| [record.date, record.created_at] }.reverse
    end

    def filtered_earnings
      scope = @user.earnings.for_year(year)
      scope = scope.for_month(month) if month
      scope = apply_earning_search(scope, query) if query.present?
      scope
    end

    def filtered_expenses
      scope = @user.expenses.for_year(year)
      scope = scope.for_month(month) if month
      scope = filter == 'unpaid' ? scope.where(paid: false) : scope.paid_only
      scope = apply_expense_search(scope, query) if query.present?
      scope
    end

    def apply_earning_search(scope, term)
      matched_platforms = enum_matches(Earning.platforms, earning_platform_labels, term)
      if matched_platforms.any?
        scope.where('notes ILIKE ? OR platform IN (?)', "%#{term}%", matched_platforms)
      else
        scope.where('notes ILIKE ?', "%#{term}%")
      end
    end

    def apply_expense_search(scope, term)
      matched_categories = enum_matches(Expense.categories, expense_category_labels, term)
      if matched_categories.any?
        scope.where('description ILIKE ? OR vendor ILIKE ? OR category IN (?)', "%#{term}%", "%#{term}%", matched_categories)
      else
        scope.where('description ILIKE ? OR vendor ILIKE ?', "%#{term}%", "%#{term}%")
      end
    end

    def enum_matches(enum_map, labels, term)
      labels.filter_map do |key, label|
        enum_map[key.to_s] if label.downcase.include?(term.downcase)
      end
    end

    def expense_category_labels
      I18n.t('activerecord.attributes.expense.categories')
    end

    def earning_platform_labels
      I18n.t('activerecord.attributes.earning.platforms')
    end

    def include_earnings?
      %w[all earnings].include?(filter)
    end

    def include_expenses?
      %w[all expenses unpaid].include?(filter)
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

    def build_summary(items)
      earnings_total = items.select { |record| record.is_a?(Earning) }.sum(&:amount)
      expenses_total = items.select { |record| record.is_a?(Expense) }.sum(&:amount)

      {
        earnings: earnings_total,
        expenses: expenses_total,
        net: earnings_total - expenses_total
      }
    end
  end
end
