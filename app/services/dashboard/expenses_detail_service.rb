module Dashboard
  class ExpensesDetailService
    def initialize(year: Date.current.year, month: nil)
      @year = year
      @month = month
    end

    def call
      return monthly_detail if @month.present?

      annual_detail
    end

    private

    attr_reader :year, :month

    def monthly_detail
      scope = Expense.for_year(year).for_month(month).chronological

      {
        expenses: scope,
        expenses_by_month: nil,
        total: scope.sum(:amount),
        annual: false
      }
    end

    def annual_detail
      by_month = Expense.for_year(year).group(Arel.sql('EXTRACT(MONTH FROM date)::int')).sum(:amount)
      month_names = I18n.t('date.month_names')
      expenses_by_month = by_month.sort_by { |month, _| month }.map do |month, total|
        { month: month, month_name: month_names[month], total: total }
      end

      {
        expenses: Expense.none,
        expenses_by_month: expenses_by_month,
        total: expenses_by_month.sum { |row| row[:total] },
        annual: true
      }
    end
  end
end
