module Plans
  module Catalog
    PLANS = {
      free: {
        price_month: BigDecimal('0'),
        features:    %i[records caju_limit single_goal history_limit]
      },
      pro:  {
        price_month: BigDecimal('14.90'),
        price_year:  BigDecimal('143.00'),
        features:    %i[exports insights goals history caju backup]
      }
    }.freeze
  end
end
