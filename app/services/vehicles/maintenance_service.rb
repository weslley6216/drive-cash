module Vehicles
  class MaintenanceService
    Row = Data.define(:maintenance, :progress, :km_until, :target, :status_key)

    EMPTY_PAYLOAD = {
      vehicle:      nil,
      odometer:     { current_km: 0, km_this_month: 0, updated_days_ago: nil },
      maintenances: [],
      insights:     []
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
        vehicle:      vehicle,
        odometer:     {
          current_km:       vehicle.odometer_km,
          km_this_month:    stats.km_this_month,
          updated_days_ago: vehicle.updated_days_ago
        },
        maintenances: build_maintenances(vehicle),
        insights:     build_insights(vehicle)
      }
    end

    private

    def build_maintenances(vehicle)
      vehicle.maintenances.sort_by { |maintenance| -maintenance.progress }.map do |maintenance|
        Row.new(
          maintenance: maintenance,
          progress:    maintenance.progress,
          km_until:    maintenance.km_until,
          target:      maintenance.target,
          status_key:  Vehicles::MaintenanceStatus.for(maintenance.progress)
        )
      end
    end

    def build_insights(vehicle)
      [cheapest_vendor_insight(vehicle)].compact
    end

    def cheapest_vendor_insight(vehicle)
      comparison = Refuelings::VendorEfficiency.new(vehicle: vehicle, date: @date).cheapest
      return nil unless comparison

      { type: :cheapest_vendor, **comparison.to_h }
    end
  end
end
