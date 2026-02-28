class Expense < ApplicationRecord
  include CacheInvalidation

  CATEGORIES_BY_GROUP = {
    vehicle: %w[fuel maintenance car_wash toll parking documentation insurance fine],
    personal_operations: %w[meals phone other]
  }.freeze

  belongs_to :trip

  before_validation :assign_trip, if: :date?

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

  validates :date, :amount, :category, presence: true
  validates :amount, numericality: { greater_than: 0 }

  scope :chronological, -> { order(date: :desc, created_at: :desc) }
  scope :for_year, ->(year) { where('EXTRACT(YEAR FROM date) = ?', year) if year.present? }
  scope :for_month, ->(month) { where('EXTRACT(MONTH FROM date) = ?', month) if month.present? }
  scope :by_category, ->(category) { where(category: category) if category.present? }

  def self.total_by_category
    group(:category).sum(:amount)
  end

  private

  def assign_trip
    self.trip ||= Trip.find_or_create_by(date: date)
  end
end
