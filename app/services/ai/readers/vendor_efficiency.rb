module Ai
  module Readers
    class VendorEfficiency
      def initialize(params, user:)
        @user = user
      end

      def call
        vehicle = @user.vehicle
        return nil unless vehicle

        Refuelings::VendorEfficiency.new(vehicle: vehicle).cheapest
      end
    end
  end
end
