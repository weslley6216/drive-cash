module Ai
  module Readers
    class LastMaintenance
      def initialize(params, user:)
        @params = params
        @user = user
      end

      def call
        vehicle = @user.vehicle
        return nil unless vehicle

        category = @params['category'].presence
        scope = vehicle.maintenances
        scope = scope.where(category: category) if category
        scope.order(:last_done_km).last
      end
    end
  end
end
