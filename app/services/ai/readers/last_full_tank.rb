module Ai
  module Readers
    class LastFullTank
      def initialize(params, user:)
        @user = user
      end

      def call
        vehicle = @user.vehicle
        return nil unless vehicle

        vehicle.refuelings.full_tank.chronological.first
      end
    end
  end
end
