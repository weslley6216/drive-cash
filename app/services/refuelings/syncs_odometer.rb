module Refuelings
  module SyncsOdometer
    private

    def sync_odometer(refueling)
      Vehicles::OdometerSync.new(vehicle: refueling.vehicle, reading_km: refueling.odometer_km, on: refueling.date).call
    end
  end
end
