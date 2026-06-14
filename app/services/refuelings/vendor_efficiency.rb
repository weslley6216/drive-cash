module Refuelings
  class VendorEfficiency
    MIN_DISTINCT_VENDORS = 3
    MIN_READINGS_PER_VENDOR = 2

    Comparison = Data.define(:winner, :winner_kml, :runner_up, :runner_up_kml, :savings)

    def initialize(vehicle:, date: Date.current)
      @vehicle = vehicle
      @date = date
    end

    def cheapest
      return nil if averages_by_vendor.size < MIN_DISTINCT_VENDORS

      winner, winner_kml = averages_by_vendor.max_by { |_vendor, kml| kml }
      runner_up, runner_up_kml = averages_by_vendor.except(winner).max_by { |_vendor, kml| kml }

      Comparison.new(
        winner:        winner,
        winner_kml:    winner_kml,
        runner_up:     runner_up,
        runner_up_kml: runner_up_kml,
        savings:       monthly_savings_estimate(winner_kml: winner_kml, runner_up_kml: runner_up_kml)
      )
    end

    private

    def full_tank_scope
      @full_tank_scope ||= @vehicle.refuelings.full_tank.where.not(vendor: [nil, ''])
    end

    def averages_by_vendor
      @averages_by_vendor ||= compute_averages_by_vendor
    end

    def compute_averages_by_vendor
      readings_by_vendor = full_tank_scope.order(:vendor, :date, :created_at).to_a.group_by(&:vendor)
      return {} if readings_by_vendor.size < MIN_DISTINCT_VENDORS

      readings_by_vendor.transform_values { |readings| average_kml_for(readings) }.compact
    end

    def average_kml_for(readings)
      return nil if readings.size < MIN_READINGS_PER_VENDOR

      ratios = readings.each_cons(2).filter_map do |previous_one, current_one|
        delta_km = current_one.odometer_km - previous_one.odometer_km
        liters_value = current_one.liters.to_f
        next if delta_km <= 0 || liters_value.zero?

        delta_km / liters_value
      end

      return nil if ratios.empty?

      ratios.sum / ratios.size
    end

    def monthly_savings_estimate(winner_kml:, runner_up_kml:)
      return 0 if runner_up_kml.nil? || winner_kml <= runner_up_kml
      return 0 if monthly_km <= 0
      return 0 if average_price_per_liter.zero?

      saved_liters = (monthly_km / runner_up_kml) - (monthly_km / winner_kml)
      (saved_liters * average_price_per_liter).round
    end

    def monthly_km
      @monthly_km ||= begin
        recent_scope = @vehicle.refuelings.where(date: (@date - 30.days)..@date)
        recent_scope.maximum(:odometer_km).to_i - recent_scope.minimum(:odometer_km).to_i
      end
    end

    def average_price_per_liter
      @average_price_per_liter ||= @vehicle.refuelings.full_tank
        .where(date: (@date - 90.days)..@date)
        .average(:price_per_liter).to_f
    end
  end
end
