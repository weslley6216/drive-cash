module Dashboard
  class CategoryBreakdownService
    def initialize(year:, month: nil, limit: 4, user: Current.user)
      @year = year
      @month = month
      @limit = limit
      @user = user
    end

    def call
      scope = @user.expenses.paid_in_period(year, month)

      total = scope.sum(:amount).to_f
      return [] if total.zero?

      scope.group(:category)
           .sum(:amount)
           .sort_by { |_category, amount| -amount }
           .first(@limit)
           .map { |category, amount| build_row(category, amount, total) }
    end

    private

    attr_reader :year, :month, :limit

    def build_row(category, amount, total)
      {
        id: category,
        label: I18n.t("activerecord.attributes.expense.categories.#{category}"),
        amount: amount,
        percent: (amount.to_f / total * 100).round(1)
      }
    end
  end
end
