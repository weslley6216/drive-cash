module Vehicles
  class MaintenanceService
    MIN_DISTINCT_VENDORS_FOR_INSIGHT = 3
    EMPTY_PAYLOAD = {
      vehicle: nil,
      odometer: { current_km: 0, km_this_month: 0, updated_days_ago: nil },
      maintenances: [],
      insights: []
    }.freeze

    def initialize(user:, date: Date.current)
      @user = user
      @date = date
    end

    def call
      vehicle = @user.vehicle
      return EMPTY_PAYLOAD unless vehicle

      stats = Statistics.new(vehicle: vehicle, date: @date)
      {
        vehicle: vehicle,
        odometer: {
          current_km: vehicle.odometer_km,
          km_this_month: stats.km_this_month,
          updated_days_ago: vehicle.updated_days_ago
        },
        maintenances: build_maintenances(vehicle),
        insights: build_insights(vehicle)
      }
    end

    private

    def build_maintenances(vehicle)
      vehicle.maintenances.includes(:vehicle).sort_by { |maintenance| -maintenance.progress }.map do |maintenance|
        {
          maintenance: maintenance,
          progress: maintenance.progress,
          km_until: maintenance.km_until,
          target: maintenance.target,
          status_key: maintenance.status_key
        }
      end
    end

    def build_insights(vehicle)
      [cheapest_vendor_insight(vehicle)].compact
    end

    def cheapest_vendor_insight(vehicle)
      full_tank_scope = vehicle.refuelings.full_tank.where.not(vendor: [nil, ''])
      vendors = full_tank_scope.distinct.pluck(:vendor)
      return nil if vendors.size < MIN_DISTINCT_VENDORS_FOR_INSIGHT

      by_vendor = vendors.index_with { |vendor| avg_for_vendor(full_tank_scope, vendor) }.compact
      return nil if by_vendor.size < MIN_DISTINCT_VENDORS_FOR_INSIGHT

      winner, winner_kml = by_vendor.max_by { |_vendor, kml| kml }
      runner_up, runner_up_kml = by_vendor.except(winner).max_by { |_vendor, kml| kml }
      savings = monthly_savings_estimate(vehicle: vehicle, winner_kml: winner_kml, runner_up_kml: runner_up_kml)

      {
        type: :cheapest_vendor,
        title: I18n.t('vehicle.insight.cheapest.title', vendor: winner),
        body: I18n.t('vehicle.insight.cheapest.body',
                     kml: format_kml(winner_kml),
                     other: format_kml(runner_up_kml),
                     other_vendor: runner_up,
                     savings: format_currency_short(savings))
      }
    end

    def format_kml(value)
      Kernel.format('%.1f', value).tr('.', ',')
    end

    def format_currency_short(value)
      ActionController::Base.helpers.number_to_currency(value, unit: 'R$ ', precision: 0, separator: ',', delimiter: '.')
    end

    def avg_for_vendor(scope, vendor)
      records = scope.where(vendor: vendor).order(:date, :created_at).to_a
      return nil if records.size < 2

      pairs = records.each_cons(2).map do |previous_one, current_one|
        delta_km = current_one.odometer_km - previous_one.odometer_km
        liters_value = current_one.liters.to_f
        next nil if delta_km <= 0 || liters_value.zero?

        delta_km / liters_value
      end.compact

      return nil if pairs.empty?

      pairs.sum / pairs.size
    end

    def monthly_savings_estimate(vehicle:, winner_kml:, runner_up_kml:)
      return 0 if runner_up_kml.nil? || winner_kml <= runner_up_kml

      monthly_km = vehicle.refuelings.where(date: (@date - 30.days)..@date).maximum(:odometer_km).to_i -
                   vehicle.refuelings.where(date: (@date - 30.days)..@date).minimum(:odometer_km).to_i
      return 0 if monthly_km <= 0

      avg_price_per_liter = vehicle.refuelings.full_tank.where(date: (@date - 90.days)..@date).average(:price_per_liter).to_f
      return 0 if avg_price_per_liter.zero?

      saved_liters = (monthly_km / runner_up_kml) - (monthly_km / winner_kml)
      (saved_liters * avg_price_per_liter).round
    end
  end
end
