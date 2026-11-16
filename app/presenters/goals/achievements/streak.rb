module Goals
  module Achievements
    class Streak < Base
      private

      def interpolations
        { days: @raw[:days] }
      end
    end
  end
end
