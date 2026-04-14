module Expenses
  class CreateService
    def initialize(params:)
      @params = params
    end

    def call
      expense = Expense.new(params)
      expense.trip ||= Trip.find_or_create_by(date: expense.date) if expense.date.present?
      expense.save
      expense
    end

    private

    attr_reader :params
  end
end
