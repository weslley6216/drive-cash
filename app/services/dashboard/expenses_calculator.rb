# app/services/dashboard/expenses_calculator.rb
module Dashboard
  class ExpensesCalculator
    def initialize(scope)
      @scope = scope
    end

    def call
      {
        total: total_expenses,
        avg_per_month: avg_per_month,
        by_category: by_category,
        top_vendors: top_vendors
      }
    end

    private

    attr_reader :scope

    def total_expenses
      @total_expenses ||= scope.sum(:amount)
    end

    def avg_per_month
      months = distinct_months_count
      return 0 if months.zero?
      total_expenses / months
    end

    def by_category
      scope.group(:category).sum(:amount)
    end

    def top_vendors
      scope.where.not(vendor: nil)
           .group(:vendor)
           .sum(:amount)
           .sort_by { |_, total| -total }
           .first(5)
           .to_h
    end

    def distinct_months_count
      @distinct_months_count ||= scope
        .pluck(Arel.sql("DISTINCT TO_CHAR(date, 'YYYY-MM')"))
        .count
        .clamp(1, Float::INFINITY)
    end
  end
end
