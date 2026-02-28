class Earning < ApplicationRecord
  include CacheInvalidation

  belongs_to :trip

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

  scope :chronological, -> { order(date: :desc, created_at: :desc) }
  scope :for_year, ->(year) { where('EXTRACT(YEAR FROM date) = ?', year) if year.present? }
  scope :for_month, ->(month) { where('EXTRACT(MONTH FROM date) = ?', month) if month.present? }
  scope :by_platform, ->(platform) { where(platform: platform) if platform.present? }

  def self.total_by_platform = group(:platform).sum(:amount)
end
