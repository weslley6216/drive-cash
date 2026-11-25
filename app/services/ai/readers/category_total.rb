module Ai
  module Readers
    class CategoryTotal
      def initialize(params, user:)
        @params = params
        @user = user
      end

      def call
        category = @params['category']
        return nil unless Expense.categories.key?(category)

        year = @params['year']&.to_i || Date.current.year
        month = @params['month']&.to_i.presence
        total = @user.expenses.paid_in_period(year, month).where(category: category).sum(:amount).to_f

        { category: category, total: total }
      end
    end
  end
end
