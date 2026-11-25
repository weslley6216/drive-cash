module Refuelings
  module SyncsOdometer
    private

    def sync_odometer(refueling)
      Vehicles::OdometerSync.new(vehicle: refueling.vehicle, reading_km: refueling.odometer_km, on: refueling.date).call
    end

    def odometer_advanced?(refueling, previous_km)
      refueling.odometer_km.present? && refueling.odometer_km.to_i > previous_km.to_i
    end
  end
end
