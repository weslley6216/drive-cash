module Refuelings
  class Updater
    Result = Data.define(:success?, :refueling)

    def self.call(refueling:, params:)
      new(refueling: refueling, params: params).call
    end

    def initialize(refueling:, params:)
      @refueling = refueling
      @params = params
    end

    def call
      Refueling.transaction do
        if @refueling.update(@params)
          sync_odometer
          Result.new(success?: true, refueling: @refueling)
        else
          Result.new(success?: false, refueling: @refueling)
        end
      end
    end

    private

    def sync_odometer
      Vehicles::OdometerSync.new(vehicle: @refueling.vehicle, reading_km: @refueling.odometer_km, on: @refueling.date).call
    end
  end
end
