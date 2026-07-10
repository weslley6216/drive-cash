class EarningsController < ApplicationController
  before_action :find_earning, only: [:edit, :update, :destroy]

  def new
    redirect_to new_record_path(type: 'earning', context: params[:context]&.permit(:year, :month))
  end

  def create
    result = create_earning_via_creator(:earning)

    if result.success?
      turbo_success(Earnings::CreateView, record: result.earning, record_key: :earning)
    else
      turbo_error(Earnings::CreateView, record: result.earning, record_key: :earning)
    end
  end

  def edit
    render Earnings::EditView.new(earning: @earning, context: params[:context])
  end

  def update
    if @earning.update(earning_attributes(:earning))
      turbo_success(Earnings::UpdateView, record: @earning, record_key: :earning, detail_service: Dashboard::EarningsDetailService)
    else
      turbo_error(Earnings::UpdateView, record: @earning, record_key: :earning)
    end
  end

  def destroy
    @earning.destroy
    turbo_render_list(Dashboard::EarningsDetailService, Dashboard::EarningsDetailView)
  end

  private

  def find_earning
    @earning = current_user.earnings.find(params[:id])
  end
end
