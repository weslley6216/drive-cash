module Ai
  module Readers
    class TankBalance
      def initialize(params, user:)
        @user = user
      end

      def call
        Vehicles::TankBalanceService.new(user: @user).call
      end
    end
  end
end
