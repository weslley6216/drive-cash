class RecordsController < ApplicationController
  before_action :find_record, only: %i[edit update destroy]

  def create
    result = Domain::Creator.call(record_params, user: current_user)

    if result.success?
      turbo_success(Domain::CreateView, record: result.record, record_key: :record)
    else
      turbo_error(Domain::CreateView, record: result.record, record_key: :record)
    end
  end

  def edit
    render Domain::EditView.new(record: @record)
  end

  def update
    if @record.update(record_params)
      turbo_success(Domain::UpdateView, record: @record, record_key: :record)
    else
      turbo_error(Domain::UpdateView, record: @record, record_key: :record)
    end
  end

  def destroy
    @record.destroy
    turbo_render_list(Dashboard::RecordsDetailService, Dashboard::RecordsDetailView)
  end

  private

  def find_record
    @record = current_user.records.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def record_params
    params.require(:record).permit(:date, :amount, :category)
  end
end
