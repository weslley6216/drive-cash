module Ai
  module Readers
    class HistorySearch
      def initialize(params, user:)
        @params = params
        @user = user
      end

      def call
        term = @params['term'].to_s
        searcher = History::RecordSearch.new(term)

        earnings = searcher.earnings(@user.earnings.order(date: :desc).limit(50)).to_a
        expenses = searcher.expenses(@user.expenses.order(date: :desc).limit(50)).to_a

        { earnings: earnings, expenses: expenses, term: term }
      end
    end
  end
end
