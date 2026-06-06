class ExpensesController < ApplicationController
  before_action :find_expense, only: [:edit, :update, :destroy]

  def new
    redirect_to new_record_path(type: 'expense', context: params[:context]&.to_unsafe_h)
  end

  def create
    result = create_expense_via_creator(:expense)

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
    if @expense.update(expense_attributes(:expense))
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

  def find_expense
    @expense = current_user.expenses.find(params[:id])
  end
end
