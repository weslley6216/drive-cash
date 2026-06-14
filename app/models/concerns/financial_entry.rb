module FinancialEntry
  extend ActiveSupport::Concern

  include MonetaryAmount
  include PeriodScoped

  included do
    belongs_to :user

    monetize :amount

    validates :date, :amount, presence: true
    validates :amount, numericality: { greater_than: 0, allow_blank: true }
  end
end
