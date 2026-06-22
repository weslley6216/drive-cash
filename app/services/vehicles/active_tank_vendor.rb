module Vehicles
  class ActiveTankVendor
    def initialize(user:)
      @user = user
    end

    def call
      vehicle = @user.vehicle
      return nil unless vehicle

      vehicle.refuelings.full_tank.chronological.first&.vendor.presence
    end
  end
end
