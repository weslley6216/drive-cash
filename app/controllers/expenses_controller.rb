class ExpensesController < ApplicationController
  def new
    @expense = Expense.new(date: Date.current)

    render Expenses::NewView.new(expense: @expense, context: params[:context])
  end

  def create
    @expense = Expense.new(expense_params)

    if @expense.save
      @view_context, @totals = build_totals_context(@expense)

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
      @view_context, _totals = build_totals_context(@expense)
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
