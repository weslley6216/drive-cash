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
    )
  end
end
