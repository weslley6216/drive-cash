class RecordsController < ApplicationController
  def new
    render new_view(type: params[:type].presence || 'earning')
  end

  def create
    builder = RecordParams::RECORD_BUILDERS[params[:type]]
    return head :bad_request unless builder

    result = send(builder[:create], :record)
    if result.success?
      redirect_to root_path, notice: t('records.create.success')
    else
      render new_view(type: params[:type], builder[:record_key] => result.public_send(builder[:record_key])),
             status: :unprocessable_content
    end
  end

  private

  def new_view(type:, earning: nil, expense: nil)
    Records::NewView.new(
      type:          type,
      earning:       earning || Earning.new(date: Date.current),
      expense:       expense || Expense.new(date: Date.current),
      context:       params[:context],
      active_vendor: Vehicles::ActiveTankVendor.new(user: current_user).call.to_s
    )
  end
end
