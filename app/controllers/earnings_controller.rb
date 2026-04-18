class EarningsController < ApplicationController
  before_action :find_earning, only: [:edit, :update, :destroy]

  def new
    earning = Earning.new(date: Date.current)

    render Earnings::NewView.new(earning: earning, context: params[:context])
  end

  def create
    earning = Earning.new(earning_params)

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
    params.require(:earning).permit(:date, :amount, :platform, :notes)
  end

  def find_earning
    @earning = Earning.find(params[:id])
  end
end
