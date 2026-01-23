class ExpensesController < ApplicationController
  def new
    @expense = Expense.new(date: Date.current)

    render Expenses::NewView.new(expense: @expense, context: params[:context])
  end

  def create
    @expense = Expense.new(expense_params)
    @expense.trip = Trip.find_or_create_by(date: @expense.date) if @expense.date.present?

    if @expense.save
      @totals = Dashboard::StatsService.new(year: context_year).call
      flash.now[:notice] = t('.success')

      respond_to do |format|
        format.turbo_stream do
          render Expenses::CreateView.new(
            expense: @expense,
            totals: @totals,
            context: params[:context] || {}
          )
        end
      end
    else
      flash.now[:alert] = @expense.errors.full_messages.to_sentence

      respond_to do |format|
        format.turbo_stream do
          render Expenses::CreateView.new(
            expense: @expense,
            totals: nil,
            context: params[:context] || {}
          ), status: :unprocessable_entity
        end
      end
    end
  end

  private

  def expense_params
    params.require(:expense).permit(:date, :amount, :category, :vendor, :description)
  end
end
