# app/controllers/earnings_controller.rb
class EarningsController < ApplicationController
  def index
    @earnings = Earning.chronological
                       .for_year(params[:year])
                       .for_month(params[:month])
    
    @total = @earnings.sum(:amount)
    
    render Earnings::IndexView.new(earnings: @earnings, total: @total)
  end

  def new
    @earning = Earning.new(date: Date.current)

    render Earnings::NewView.new(earning: @earning)
  end

  def create
    @earning = Earning.new(earning_params)

    if @earning.save
      flash.now[:notice] = 'Receita criada com sucesso!'
      redirect_to earnings_path
    else
      flash.now[:alert] = 'Erro ao criar receita'
      render Earnings::NewView.new(earning: @earning)
    end
  end

  private

  def earning_params
    params.require(:earning).permit(:date, :amount, :platform, :notes)
  end
end
