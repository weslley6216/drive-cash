class ExpensesController < ApplicationController
  before_action :find_expense, only: [:edit, :update, :destroy]

  def new
    expense = Expense.new(date: Date.current)

    render Expenses::NewView.new(expense: expense, context: params[:context])
  end

  def create
    result = Expenses::Creator.call(
      expense_params.to_unsafe_h,
      installment_params.to_unsafe_h
    )

    if result.success?
      turbo_success(Expenses::CreateView, expense: result.expenses.first)
    else
      turbo_error(Expenses::NewView, expense: result.expense)
    end
  end

  def edit
    render Expenses::EditView.new(expense: @expense, context: params[:context])
  end

  def update
    if @expense.update(expense_params)
      turbo_success(Expenses::UpdateView, expense: @expense)
    else
      turbo_error(Expenses::UpdateView, expense: @expense)
    end
  end

  def destroy
    @expense.destroy
    turbo_render_list(Dashboard::ExpensesDetailService, Dashboard::ExpensesDetailView)
  end

  private

  def expense_params
    params.require(:expense).permit(:date, :amount, :category, :vendor, :description, :paid)
  end

  def installment_params
    params.fetch(:installment, {}).permit(:repeat, :period, :repetitions)
  end

  def find_expense
    @expense = Expense.find(params[:id])
  end
end
