module OutcomeLabels
  private

  def kind_label
    t("goals.outcomes.show.kinds.#{@outcome.goal.kind}")
  end

  def metric_label
    t("goals.outcomes.show.metrics.#{@outcome.goal.metric}")
  end

  def period_label
    Goals::PeriodLabel.new(kind: @outcome.goal.kind, period: @outcome.goal.period_start..@outcome.goal.period_end)
  end
end
