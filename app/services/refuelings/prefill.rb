module Refuelings
  class Prefill
    def self.call(user:)
      new(user: user).call
    end

    def initialize(user:)
      @user = user
    end

    def call
      @user.vehicle.refuelings.new(
        date:        Date.current,
        full_tank:   true,
        vendor:      Vehicles::ActiveTankVendor.new(user: @user).call,
        odometer_km: @user.vehicle.odometer_km
      )
    end
  end
end
