module PeriodScoped
  extend ActiveSupport::Concern

  included do
    scope :chronological, -> { order(date: :desc, created_at: :desc) }

    scope :for_year, lambda { |year|
      next all if year.blank?

      start_of_year = Date.new(year.to_i, 1, 1)
      where(date: start_of_year..start_of_year.end_of_year)
    }

    scope :for_month, lambda { |month|
      next all if month.blank?

      where('EXTRACT(MONTH FROM date) = ?', month)
    }

    scope :in_period, lambda { |year, month = nil|
      relation = for_year(year)
      month ? relation.for_month(month) : relation
    }
  end
end
