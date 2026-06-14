module Dashboard
  module Insights
    class WorstPlatform
      def initialize(context)
        @context = context
      end

      def call
        return nil if @context.platforms.size < 2

        worst = @context.platforms.last
        trips = worst[:trips_count].to_i
        return nil if trips.zero?

        {
          type:     'worst_platform',
          severity: 'info',
          payload:  {
            platform: worst[:label],
            per_trip: (worst[:amount].to_f / trips).round(2)
          }
        }
      end
    end
  end
end
