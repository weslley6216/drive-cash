class ExpensesController < ApplicationController
  def new
    @expense = Expense.new(date: Date.current)

    render Expenses::NewView.new(expense: @expense, context: params[:context])
  end

  def create
    @expense = Expense.new(expense_params)
    @expense.trip = Trip.find_or_create_by(date: @expense.date) if @expense.date.present?

    if @expense.save
      @view_context = dashboard_context(@expense)
      @totals = Dashboard::StatsService.new(**@view_context).call

      flash.now[:notice] = t('.success')

      respond_to do |format|
        format.turbo_stream do
          render Expenses::CreateView.new(
            expense: @expense,
            totals: @totals,
            context: @view_context
          )
        end
      end
    else
      @view_context = dashboard_context(@expense)
      flash.now[:alert] = @expense.errors.full_messages.to_sentence

      respond_to do |format|
        format.turbo_stream do
          render Expenses::CreateView.new(
            expense: @expense,
            totals: nil,
            context: @view_context
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
