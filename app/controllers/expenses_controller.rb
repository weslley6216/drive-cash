class ExpensesController < ApplicationController
  include RecordRedirect

  before_action :find_expense, only: [:edit, :update, :destroy]

  def new
    redirect_to_new_record('expense')
  end

  def create
    result = create_expense_via_creator(:expense)

    if result.success?
      turbo_success(Expenses::CreateView, record: result.expenses.first, record_key: :expense)
    else
      turbo_error(Expenses::NewView, record: result.expense, record_key: :expense,
                                     active_vendor: Vehicles::ActiveTankVendor.new(user: current_user).call.to_s)
    end
  end

  def edit
    render Expenses::EditView.new(expense: @expense, context: params[:context])
  end

  def update
    if @expense.update(expense_attributes(:expense))
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
