module Dashboard
  class CategoryBreakdownService < BreakdownService
    private

    def default_limit = 4

    def aggregates
      user.expenses.paid_in_period(year, month)
          .group(:category)
          .sum(:amount)
          .map { |category, amount| { id: category, amount: amount } }
    end

    def build_row(row)
      {
        id: row[:id],
        label: I18n.t("activerecord.attributes.expense.categories.#{row[:id]}"),
        amount: row[:amount],
        percent: percent(row[:amount])
      }
    end
  end
end
