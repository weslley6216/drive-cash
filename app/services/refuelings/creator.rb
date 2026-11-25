module Refuelings
  class Creator
    include SyncsOdometer

    def self.call(vehicle:, params:)
      new(vehicle: vehicle, params: params).call
    end

    def initialize(vehicle:, params:)
      @vehicle = vehicle
      @params = params
    end

    def call
      refueling = @vehicle.refuelings.new(@params)
      previous_km = @vehicle.odometer_km

      Refueling.transaction do
        if refueling.save
          sync_odometer(refueling)
          Result.new(success?: true, refueling: refueling, odometer_advanced: odometer_advanced?(refueling, previous_km))
        else
          Result.new(success?: false, refueling: refueling, odometer_advanced: false)
        end
      end
    end
  end
end
