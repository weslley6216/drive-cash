class EarningsController < ApplicationController
  def edit
    @earning = Earning.find(params[:id])

    render Earnings::EditView.new(earning: @earning, context: params[:context])
  end

  def update
    @earning = Earning.find(params[:id])

    if @earning.update(earning_params)
      @view_context, @totals = build_totals_context(@earning)
      flash.now[:notice] = t('.success')

      respond_to do |format|
        format.turbo_stream do
          render Earnings::UpdateView.new(
            earning: @earning,
            totals: @totals,
            context: @view_context
          )
        end
      end
    else
      @view_context, _totals = build_totals_context(@earning)
      flash.now[:alert] = @earning.errors.full_messages.to_sentence

      respond_to do |format|
        format.turbo_stream do
          render Earnings::UpdateView.new(
            earning: @earning,
            totals: nil,
            context: @view_context
          ), status: :unprocessable_content
        end
      end
    end
  end

  private

  def earning_params
    params.require(:earning).permit(:date, :amount, :platform, :notes)
  end
end
