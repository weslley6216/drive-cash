class ExpensesController < ApplicationController
  def new
    render Expenses::NewView.new(expense: Expense.new(date: Date.current), context: params[:context])
  end

  def create
    @expense = Expense.new(expense_params)

    if @expense.save
      turbo_success(Expenses::CreateView, expense: @expense)
    else
      turbo_error(Expenses::CreateView, expense: @expense)
    end
  end

  def edit
    render Expenses::EditView.new(expense: Expense.find(params[:id]), context: params[:context])
  end

  def update
    @expense = Expense.find(params[:id])

    if @expense.update(expense_params)
      turbo_success(Expenses::UpdateView, expense: @expense)
    else
      turbo_error(Expenses::UpdateView, expense: @expense)
    end
  end

  private

  def expense_params
    params.require(:expense).permit(:date, :amount, :category, :vendor, :description)
  end
end
