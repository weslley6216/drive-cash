module Notifications
  module Generators
    class TankLow
      ALERT_STATUSES = %i[negative critical].freeze

      def initialize(context)
        @context = context
      end

      def call
        tank = Vehicles::TankBalanceService.new(user: @context.user).call
        return [] unless ALERT_STATUSES.include?(tank[:status_key])

        [{
          kind:  'tank_low',
          data:  {
            'status'       => tank[:status_key].to_s,
            'balance'      => tank[:balance].to_f,
            'last_fill_id' => tank[:last_fill]&.id
          },
          dedup: { 'status' => tank[:status_key].to_s, 'last_fill_id' => tank[:last_fill]&.id }
        }]
      end
    end
  end
end
