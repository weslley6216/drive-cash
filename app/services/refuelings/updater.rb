module Refuelings
  class Updater
    include SyncsOdometer

    def self.call(refueling:, params:)
      new(refueling: refueling, params: params).call
    end

    def initialize(refueling:, params:)
      @refueling = refueling
      @params = params
    end

    def call
      previous_km = @refueling.vehicle.odometer_km

      Refueling.transaction do
        if @refueling.update(@params)
          sync_odometer(@refueling)
          Result.new(success?: true, refueling: @refueling, odometer_advanced: odometer_advanced?(@refueling, previous_km))
        else
          Result.new(success?: false, refueling: @refueling, odometer_advanced: false)
        end
      end
    end
  end
end
