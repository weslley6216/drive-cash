class Earning < ApplicationRecord
  include CacheInvalidation
  include MonetaryAmount

  enum :platform, {
    amazon: 0,
    ifood: 1,
    mercado_livre: 2,
    nine_nine: 3,
    rappi: 4,
    shopee: 5,
    uber: 6,
    other: 7
  }, prefix: true

  validates :date, :amount, presence: true
  validates :amount, numericality: { greater_than: 0 }
  validates :trips_count, numericality: { greater_than_or_equal_to: 1, only_integer: true }

  scope :chronological, -> { order(date: :desc, created_at: :desc) }
  scope :for_year, ->(year) { where('EXTRACT(YEAR FROM date) = ?', year) if year.present? }
  scope :for_month, ->(month) { where('EXTRACT(MONTH FROM date) = ?', month) if month.present? }
end
