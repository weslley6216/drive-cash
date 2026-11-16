module Goals
  module Achievements
    class GoalCompleted < Base
      private

      def interpolations
        { period: I18n.l(@raw[:period_start], format: '%B').capitalize, percent: @raw[:percent].round }
      end
    end
  end
end
