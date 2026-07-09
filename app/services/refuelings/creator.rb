module Refuelings
  class Creator
    Result = Data.define(:success?, :refueling)

    def self.call(vehicle:, params:)
      new(vehicle: vehicle, params: params).call
    end

    def initialize(vehicle:, params:)
      @vehicle = vehicle
      @params = params
    end

    def call
      refueling = @vehicle.refuelings.new(@params)

      Refueling.transaction do
        if refueling.save
          sync_odometer(refueling)
          Result.new(success?: true, refueling: refueling)
        else
          Result.new(success?: false, refueling: refueling)
        end
      end
    end

    private

    def sync_odometer(refueling)
      Vehicles::OdometerSync.new(vehicle: @vehicle, reading_km: refueling.odometer_km, on: refueling.date).call
    end
  end
end
