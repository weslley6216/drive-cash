class EarningsController < ApplicationController
  before_action :find_earning, only: [:edit, :update, :destroy]

  def edit
    render Records::EditView.new(earning: @earning, context: params[:context])
  end

  def update
    if @earning.update(earning_attributes(:record))
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
