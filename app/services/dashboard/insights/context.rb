module Dashboard
  module Insights
    Context = Data.define(
      :user,
      :year,
      :month,
      :previous_year,
      :previous_month,
      :current_stats,
      :previous_stats,
      :categories,
      :platforms
    ) do
      def initialize(previous_year: nil, previous_month: nil, previous_stats: nil, **attributes)
        super
      end
    end
  end
end
