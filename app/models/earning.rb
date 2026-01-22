# app/models/earning.rb
class Earning < ApplicationRecord
  enum :platform, {
    shopee: 'shopee',
    ifood: 'ifood',
    uber: 'uber',
    nine_nine: '99',
    other: 'other'
  }, prefix: true

  validates :date, :amount, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 0 }

  scope :chronological, -> { order(date: :desc) }
  scope :for_year, ->(year) { where('EXTRACT(YEAR FROM date) = ?', year) if year.present? }
  scope :for_month, ->(month) { where('EXTRACT(MONTH FROM date) = ?', month) if month.present? }
end
