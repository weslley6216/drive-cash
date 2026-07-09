class EarningsController < ApplicationController
  before_action :find_earning, only: [:edit, :update, :destroy]

  def new
    redirect_to new_record_path(type: 'earning', context: params[:context]&.to_unsafe_h)
  end

  def create
    result = create_earning_via_creator(:earning)

    if result.success?
      turbo_success(Earnings::CreateView, earning: result.earning)
    else
      turbo_error(Earnings::CreateView, earning: result.earning)
    end
  end

  def edit
    render Earnings::EditView.new(earning: @earning, context: params[:context])
  end

  def update
    if @earning.update(earning_attributes(:earning))
      turbo_success(Earnings::UpdateView, detail_service: Dashboard::EarningsDetailService, earning: @earning)
    else
      turbo_error(Earnings::UpdateView, earning: @earning)
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
