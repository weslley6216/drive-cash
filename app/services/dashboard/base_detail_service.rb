module Dashboard
  class BaseDetailService
    def initialize(year: Date.current.year, month: nil)
      @year = year
      @month = month
    end

    def call
      return monthly_detail if month.present?

      annual_detail
    end

    private

    attr_reader :year, :month

    def monthly_detail
      scope = base_scope.for_year(year).for_month(month).chronological

      {
        list_key => scope,
        by_month_key => nil,
        total: scope.sum(:amount),
        annual: false
      }
    end

    def annual_detail
      by_month = base_scope.for_year(year)
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

    def month_names
      I18n.t('date.month_names')
    end

    def base_scope
      raise NotImplementedError
    end

    def empty_scope
      raise NotImplementedError
    end

    def list_key
      raise NotImplementedError
    end

    def by_month_key
      raise NotImplementedError
    end
  end
end
