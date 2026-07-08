module Goals
  class MetricValue
    def self.of(goal, earned:, spent:)
      goal.metric_profit? ? earned - spent : earned
    end
  end
end
