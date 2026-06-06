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

  def create
    case params[:type]
    when 'earning' then create_earning
    when 'expense' then create_expense
    else head :bad_request
    end
  end

  private

  def create_earning
    earning = Earning.new(earning_attributes(:record).merge(user: current_user))

    if earning.save
      redirect_to root_path, notice: t('records.create.success')
    else
      render Records::NewView.new(
        type: 'earning',
        earning: earning,
        expense: Expense.new(date: Date.current),
        context: params[:context]
      ), status: :unprocessable_content
    end
  end

  def create_expense
    result = create_expense_via_creator(:record)

    if result.success?
      redirect_to root_path, notice: t('records.create.success')
    else
      render Records::NewView.new(
        type: 'expense',
        earning: Earning.new(date: Date.current),
        expense: result.expense,
        context: params[:context]
      ), status: :unprocessable_content
    end
  end
end
