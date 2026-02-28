module ExpensesHelper
  def expense_category_options
    Expense::CATEGORIES_BY_GROUP.map do |group_key, categories|
      [
        I18n.t("expenses.category_groups.#{group_key}"),
        categories.map { |cat| [Expense.human_enum_name(:category, cat), cat] }
      ]
    end
  end
end
