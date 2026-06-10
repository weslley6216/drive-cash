class Vehicle
  class Statistics
    PERIOD_DAYS = 90
    VEHICLE_EXPENSE_CATEGORIES = Expense::CATEGORIES_BY_GROUP[:vehicle].freeze

    def initialize(vehicle:, date: Date.current)
      @vehicle = vehicle
      @date = date
    end

    def km_this_month
      first = @vehicle.refuelings
                      .where(date: @date.beginning_of_month..@date.end_of_month)
                      .order(:date, :created_at)
                      .first
      return 0 unless first

      [@vehicle.odometer_km - first.odometer_km, 0].max
    end

    def cost_per_km
      kms = km_in_period
      return 0 if kms.zero?

      (expenses_total_in_period / kms.to_f).round(2)
    end

    def revenue_per_km
      kms = km_in_period
      return 0 if kms.zero?

      (earnings_total_in_period / kms.to_f).round(2)
    end

    def profit_per_km
      (revenue_per_km - cost_per_km).round(2)
    end

    def avg_km_per_liter
      full_tank_refuelings = @vehicle.refuelings.full_tank.order(:date, :created_at).to_a
      return nil if full_tank_refuelings.size < 2

      pairs = full_tank_refuelings.each_cons(2).map do |previous_one, current_one|
        delta_km = current_one.odometer_km - previous_one.odometer_km
        liters_value = current_one.liters.to_f
        next nil if delta_km <= 0 || liters_value.zero?

        delta_km / liters_value
      end.compact

      return nil if pairs.empty?

      (pairs.sum / pairs.size).round(2)
    end

    private

    def km_in_period
      first = period_refuelings.order(:date, :created_at).first
      return 0 unless first

      [@vehicle.odometer_km - first.odometer_km, 0].max
    end

    def period_refuelings
      @vehicle.refuelings.where(date: period_start..@date)
    end

    def expenses_total_in_period
      @vehicle.user.expenses
              .where(date: period_start..@date, category: VEHICLE_EXPENSE_CATEGORIES)
              .sum(:amount)
              .to_f
    end

    def earnings_total_in_period
      @vehicle.user.earnings
              .where(date: period_start..@date)
              .sum(:amount)
              .to_f
    end

    def period_start
      @date - PERIOD_DAYS.days
    end
  end
end
