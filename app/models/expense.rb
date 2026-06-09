class Expense < ApplicationRecord
  include MonetaryAmount

  belongs_to :user

  CATEGORIES_BY_GROUP = {
    vehicle: %w[fuel maintenance car_wash toll parking documentation insurance fine],
    personal_operations: %w[meals phone other]
  }.freeze

  enum :category, {
    car_wash: 0,
    documentation: 1,
    fine: 2,
    fuel: 3,
    insurance: 4,
    maintenance: 5,
    meals: 6,
    parking: 7,
    phone: 8,
    toll: 9,
    other: 10
  }, prefix: true

  INSTALLMENT_PERIODS = %w[weekly biweekly monthly annual].freeze

  validates :date, :amount, :category, presence: true
  validates :amount, numericality: { greater_than: 0, allow_blank: true }
  validate :installment_fields_consistent

  scope :chronological, -> { order(date: :desc, created_at: :desc) }
  scope :paid_only, -> { where(paid: true) }
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

  scope :paid_in_period, lambda { |year, month = nil|
    relation = paid_only.for_year(year)
    month ? relation.for_month(month) : relation
  }

  def installment?
    installment_series_id.present?
  end

  private

  def installment_fields_consistent
    return if installment_series_id.blank?

    if installment_number.blank? || installment_count.blank?
      errors.add(:base, :installment_fields)
    elsif installment_number > installment_count
      errors.add(:base, :installment_order)
    end
  end
end
