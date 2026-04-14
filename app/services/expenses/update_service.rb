module Expenses
  class UpdateService
    def initialize(expense:, params:)
      @expense = expense
      @params = params
    end

    def call
      assign_trip_from_date
      expense.update(params)
      expense
    end

    private

    attr_reader :expense, :params

    def assign_trip_from_date
      date = params[:date].presence || expense.date
      return unless date.present?

      expense.trip = Trip.find_or_create_by(date: date)
    end
  end
end
