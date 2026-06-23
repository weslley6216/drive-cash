class RecordsController < ApplicationController
  def new
    @type = (params[:type].presence || 'earning')
    render Records::NewView.new(
      type:          @type,
      earning:       Earning.new(date: Date.current),
      expense:       Expense.new(date: Date.current),
      context:       params[:context],
      active_vendor: Vehicles::ActiveTankVendor.new(user: current_user).call.to_s
    )
  end

  def create
    case params[:type]
    when 'earning'
      result = create_earning_via_creator(:record)
      if result.success?
        redirect_to root_path, notice: t('records.create.success')
      else
        render Records::NewView.new(
          type:    'earning',
          earning: result.earning,
          expense: Expense.new(date: Date.current),
          context: params[:context]
        ), status: :unprocessable_content
      end
    when 'expense'
      result = create_expense_via_creator(:record)
      if result.success?
        redirect_to root_path, notice: t('records.create.success')
      else
        render Records::NewView.new(
          type:          'expense',
          earning:       Earning.new(date: Date.current),
          expense:       result.expense,
          context:       params[:context],
          active_vendor: Vehicles::ActiveTankVendor.new(user: current_user).call.to_s
        ), status: :unprocessable_content
      end
    else
      head :bad_request
    end
  end
end
