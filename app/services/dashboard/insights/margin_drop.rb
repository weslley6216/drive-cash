module Dashboard
  module Insights
    class MarginDrop
      THRESHOLD = 5.0

      def initialize(context)
        @context = context
      end

      def call
        current_margin  = MetricsCalculator.from_stats(@context.current_stats).margin
        previous_margin = MetricsCalculator.from_stats(@context.previous_stats).margin
        pp_diff = (current_margin - previous_margin).round(1)
        return nil if previous_margin.zero? || pp_diff >= -THRESHOLD

        {
          type: 'margin_drop',
          severity: 'critical',
          payload: { pp: pp_diff.abs, current_margin: current_margin }
        }
      end
    end
  end
end
