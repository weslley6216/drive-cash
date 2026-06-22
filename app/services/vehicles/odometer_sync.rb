module Vehicles
  class OdometerSync
    def initialize(vehicle:, reading_km:, on:)
      @vehicle = vehicle
      @reading_km = reading_km
      @on = on
    end

    def call
      return @vehicle if @reading_km.blank?
      return @vehicle if @reading_km.to_i <= @vehicle.odometer_km.to_i

      @vehicle.update!(odometer_km: @reading_km.to_i, odometer_updated_at: @on)
      @vehicle
    end
  end
end
