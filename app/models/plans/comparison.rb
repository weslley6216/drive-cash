module Plans
  class Comparison
    MONTHS_PER_YEAR = 12

    def free_price_month = free.fetch(:price_month)

    def free_features = free.fetch(:features)

    def pro_price_month = pro.fetch(:price_month)

    def pro_price_year = pro.fetch(:price_year)

    def pro_features = pro.fetch(:features)

    def pro_monthly_equivalent = pro_price_year / MONTHS_PER_YEAR

    def yearly_discount_percent
      full_year = pro_price_month * MONTHS_PER_YEAR

      ((full_year - pro_price_year) / full_year * 100).round
    end

    private

    def free = Catalog::PLANS.fetch(:free)

    def pro = Catalog::PLANS.fetch(:pro)
  end
end
