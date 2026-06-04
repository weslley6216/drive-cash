class EarningsController < ApplicationController
  before_action :find_earning, only: [:edit, :update, :destroy]

  def new
    redirect_to new_record_path(type: 'earning', context: params[:context]&.to_unsafe_h)
  end

  def create
    earning = current_user.earnings.new(earning_params)

    if earning.save
      turbo_success(Earnings::CreateView, earning: earning)
    else
      turbo_error(Earnings::CreateView, earning: earning)
    end
  end

  def edit
    render Earnings::EditView.new(earning: @earning, context: params[:context])
  end

  def update
    if @earning.update(earning_params)
      turbo_success(Earnings::UpdateView, earning: @earning)
    else
      turbo_error(Earnings::UpdateView, earning: @earning)
    end
  end

  def destroy
    @earning.destroy
    turbo_render_list(Dashboard::EarningsDetailService, Dashboard::EarningsDetailView)
  end

  private

  def earning_params
    params.require(:earning).permit(:date, :amount, :platform, :notes, :trips_count)
  end

  def find_earning
    @earning = current_user.earnings.find(params[:id])
  end
end
