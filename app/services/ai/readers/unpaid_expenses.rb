module Ai
  module Readers
    class UnpaidExpenses
      def initialize(params, user:)
        @user = user
      end

      def call
        @user.expenses.where(paid: false).order(:date).to_a
      end
    end
  end
end
