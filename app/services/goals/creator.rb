module Goals
  class Creator
    Result = Data.define(:success?, :goal) do
      def self.success(goal:) = new(success?: true, goal: goal)
      def self.failure(goal:) = new(success?: false, goal: goal)
    end

    def initialize(attrs, user:, date: Date.current)
      @attrs = attrs
      @user = user
      @date = date
    end

    def call
      goal = @user.goals.new(permitted_attrs)
      fill_period!(goal)

      goal.save ? Result.success(goal: goal) : Result.failure(goal: goal)
    rescue ArgumentError => e
      goal ||= @user.goals.new
      goal.errors.add(:kind, e.message)
      Result.failure(goal: goal)
    end

    private

    def permitted_attrs
      {
        'kind'          => @attrs['kind'],
        'metric'        => @attrs['metric'] || 'profit',
        'target_amount' => @attrs['target_amount']
      }
    end

    def fill_period!(goal)
      case goal.kind
      when 'weekly'
        goal.period_start = @date.beginning_of_week
        goal.period_end = @date.end_of_week
      when 'monthly'
        goal.period_start = @date.beginning_of_month
        goal.period_end = @date.end_of_month
      when 'annual'
        goal.period_start = Date.new(@date.year, 1, 1)
        goal.period_end = Date.new(@date.year, 12, 31)
      end
    end
  end
end
