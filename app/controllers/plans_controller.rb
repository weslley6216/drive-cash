class PlansController < ApplicationController
  def show
    render show_view
  end

  def update
    redirect_to plan_path, notice: t('plans.flash.checkout_soon')
  end

  private

  def show_view
    return Plans::SubscriptionView.new(subscription: Plans::Subscription.new(current_user), unread_count: current_user.unread_notifications_count) if current_user.pro?

    Plans::ShowView.new(comparison: Plans::Comparison.new, unread_count: current_user.unread_notifications_count)
  end
end
