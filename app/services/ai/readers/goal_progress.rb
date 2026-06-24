module Ai
  module Readers
    class GoalProgress
      def initialize(params, user:)
        @user = user
      end

      def call
        Goals::ProgressService.new(user: @user).call
      end
    end
  end
end
