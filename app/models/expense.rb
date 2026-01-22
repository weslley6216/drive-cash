class Expense < ApplicationRecord
  belongs_to :trip

  enum :category, {
    maintenance: 'maintenance',
    fuel: 'fuel',
    insurance: 'insurance',
    parking: 'parking',
    other: 'other'
  }, prefix: true

  validates :date, :amount, :category, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 0 }

  scope :chronological, -> { order(date: :desc) }
  scope :for_year, ->(year) { where('EXTRACT(YEAR FROM date) = ?', year) if year.present? }
  scope :for_month, ->(month) { where('EXTRACT(MONTH FROM date) = ?', month) if month.present? }
  scope :by_category, ->(category) { where(category: category) if category.present? }

  def self.total_by_category
    group(:category).sum(:amount)
  end
end
