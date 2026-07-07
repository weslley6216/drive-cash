module Goals
  class Creator
    Result = Data.define(:success?, :goal) do
      def self.success(goal:) = new(success?: true, goal: goal)
      def self.failure(goal:) = new(success?: false, goal: goal)
    end

    PERIOD_BUILDERS = {
      'weekly'  => ->(date) { [date.beginning_of_week, date.end_of_week] },
      'monthly' => ->(date) { [date.beginning_of_month, date.end_of_month] },
      'annual'  => ->(date) { [Date.new(date.year, 1, 1), Date.new(date.year, 12, 31)] }
    }.freeze

    def initialize(attrs, user:, date: Date.current)
      @attrs = attrs
      @user = user
      @date = date
    end

    def call
      return invalid('goals.errors.invalid_kind') unless Goal::KINDS.include?(@attrs['kind'])
      return invalid('goals.errors.invalid_metric') unless Goal::METRICS.include?(resolved_metric)

      goal = @user.goals.new(permitted_attrs)
      fill_period!(goal)
      goal.save ? Result.success(goal: goal) : Result.failure(goal: goal)
    end

    private

    def resolved_metric
      @attrs['metric'] || 'profit'
    end

    def invalid(message_key)
      goal = @user.goals.new
      goal.errors.add(:base, I18n.t(message_key))
      Result.failure(goal: goal)
    end

    def permitted_attrs
      {
        'kind'          => @attrs['kind'],
        'metric'        => resolved_metric,
        'target_amount' => @attrs['target_amount']
      }
    end

    def fill_period!(goal)
      goal.period_start, goal.period_end = PERIOD_BUILDERS.fetch(goal.kind).call(@date)
    end
  end
end
