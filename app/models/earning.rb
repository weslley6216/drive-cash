class Earning < ApplicationRecord
  include FinancialEntry

  enum :platform, {
    amazon:        0,
    ifood:         1,
    mercado_livre: 2,
    nine_nine:     3,
    rappi:         4,
    shopee:        5,
    uber:          6,
    other:         7
  }, prefix: true

  validates :trips_count, numericality: { greater_than_or_equal_to: 1, only_integer: true }
end
