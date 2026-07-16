class PlansController < ApplicationController
  def show
    render Plans::ShowView.new(comparison: Plans::Comparison.new)
  end

  def update
    redirect_to plan_path, notice: t('plans.flash.checkout_soon')
  end
end
