class PlansController < ApplicationController
  def show
    render show_view
  end

  def update
    redirect_to plan_path, notice: t('plans.flash.checkout_soon')
  end

  private

  def show_view
    return Plans::SubscriptionView.new(subscription: Plans::Subscription.new(current_user)) if current_user.pro?

    Plans::ShowView.new(comparison: Plans::Comparison.new)
  end
end
