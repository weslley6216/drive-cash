module Dashboard
  class ExpensesDetailService < BaseDetailService
    private

    def monthly_detail
      scope = base_scope.for_year(year).for_month(month).chronological

      {
        list_key => scope,
        by_month_key => nil,
        total: scope.paid_only.sum(:amount),
        annual: false
      }
    end

    def annual_detail
      by_month = base_scope.for_year(year).paid_only
                           .group(Arel.sql('EXTRACT(MONTH FROM date)::int'))
                           .sum(:amount)

      monthly_rows = by_month.sort_by { |month_number, _| month_number }.map do |month_number, total|
        { month: month_number, month_name: month_names[month_number], total: total }
      end

      {
        list_key => empty_scope,
        by_month_key => monthly_rows,
        total: monthly_rows.sum { |row| row[:total] },
        annual: true
      }
    end

    def base_scope
      Expense
    end

    def empty_scope
      Expense.none
    end

    def list_key
      :expenses
    end

    def by_month_key
      :expenses_by_month
    end
  end
end
