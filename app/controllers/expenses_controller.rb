class ExpensesController < ApplicationController
  before_action :find_expense, only: [:edit, :update, :destroy]

  def edit
    render Records::EditView.new(expense: @expense, context: params[:context])
  end

  def update
    if @expense.update(expense_attributes(:record))
      turbo_success(Expenses::UpdateView, record: @expense, record_key: :expense, detail_service: Dashboard::ExpensesDetailService)
    else
      turbo_error(Expenses::UpdateView, record: @expense, record_key: :expense)
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
