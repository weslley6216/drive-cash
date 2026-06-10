module Vehicles
  class MaintenanceService
    RECENT_LIMIT = 5
    PROGRESS_KM_WINDOW = 3000
    MIN_DISTINCT_VENDORS_FOR_INSIGHT = 3

    def initialize(user:, date: Date.current)
      @user = user
      @date = date
    end

    def call
      vehicle = @user.vehicle
      return empty_payload unless vehicle

      stats = Statistics.new(vehicle: vehicle, date: @date)

      {
        vehicle: vehicle,
        odometer: { current_km: vehicle.odometer_km, km_this_month: stats.km_this_month },
        metrics: {
          cost_per_km: stats.cost_per_km,
          revenue_per_km: stats.revenue_per_km,
          profit_per_km: stats.profit_per_km,
          km_per_liter: stats.avg_km_per_liter
        },
        upcoming_maintenances: build_upcoming_maintenances(vehicle),
        recent_refuelings: build_recent_refuelings(vehicle),
        insights: build_insights(vehicle)
      }
    end

    private

    def empty_payload
      {
        vehicle: nil,
        odometer: { current_km: 0, km_this_month: 0 },
        metrics: { cost_per_km: 0, revenue_per_km: 0, profit_per_km: 0, km_per_liter: nil },
        upcoming_maintenances: [],
        recent_refuelings: [],
        insights: []
      }
    end

    def build_upcoming_maintenances(vehicle)
      vehicle.maintenances.pending.order(:due_at_date, :due_at_km).map do |maintenance|
        km_value = maintenance.km_until
        days_value = maintenance.days_until(today: @date)
        {
          maintenance: maintenance,
          km_until: km_value,
          days_until: days_value,
          urgent: maintenance.urgent?(today: @date),
          progress_pct: progress_pct_for(km_value)
        }
      end
    end

    def progress_pct_for(km_value)
      return 0 if km_value.nil?

      (100 - [(km_value.to_f / PROGRESS_KM_WINDOW) * 100, 100].min).round
    end

    def build_recent_refuelings(vehicle)
      vehicle.refuelings.chronological.limit(RECENT_LIMIT).map do |refueling|
        { refueling: refueling, computed_km_per_liter: refueling.km_per_liter_to_previous }
      end
    end

    def build_insights(vehicle)
      cheapest = cheapest_vendor_insight(vehicle)
      [cheapest].compact
    end

    def cheapest_vendor_insight(vehicle)
      full_tank_scope = vehicle.refuelings.full_tank.where.not(vendor: [nil, ''])
      vendors = full_tank_scope.distinct.pluck(:vendor)
      return nil if vendors.size < MIN_DISTINCT_VENDORS_FOR_INSIGHT

      by_vendor = vendors.index_with do |vendor|
        avg_for_vendor(full_tank_scope, vendor)
      end.compact

      return nil if by_vendor.size < MIN_DISTINCT_VENDORS_FOR_INSIGHT

      winner, winner_kml = by_vendor.max_by { |_vendor, kml| kml }
      runner_up_kml = by_vendor.except(winner).values.max

      savings = monthly_savings_estimate(vehicle: vehicle, winner_kml: winner_kml, runner_up_kml: runner_up_kml)

      {
        type: :cheapest_vendor,
        title: I18n.t('vehicle.insights.cheapest_vendor.title', vendor: winner),
        description: I18n.t('vehicle.insights.cheapest_vendor.description',
                            km_per_l: format('%.1f', winner_kml).tr('.', ','),
                            savings: format_currency_short(savings))
      }
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
