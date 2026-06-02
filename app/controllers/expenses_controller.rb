class ExpensesController < ApplicationController
  before_action :find_expense, only: [:edit, :update, :destroy]

  def new
    redirect_to new_record_path(type: 'expense', context: params[:context]&.to_unsafe_h)
  end

  def create
    result = Expenses::Creator.call(
      expense_params.to_unsafe_h.merge('user_id' => Current.user.id),
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
    @expense = Current.user.expenses.find(params[:id])
  end
end
