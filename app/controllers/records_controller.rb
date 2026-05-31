class RecordsController < ApplicationController
  def new
    @type = (params[:type].presence || 'earning')
    @earning = Earning.new(date: Date.current)
    @expense = Expense.new(date: Date.current)

    render Records::NewView.new(
      type: @type,
      earning: @earning,
      expense: @expense,
      context: params[:context]
    )
  end
end
