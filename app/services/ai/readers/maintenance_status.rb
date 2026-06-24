module Ai
  module Readers
    class MaintenanceStatus
      def initialize(params, user:)
        @user = user
      end

      def call
        Vehicles::MaintenanceService.new(user: @user).call
      end
    end
  end
end
