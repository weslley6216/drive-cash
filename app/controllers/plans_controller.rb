class PlansController < ApplicationController
  def show
    render Plans::ShowView.new(comparison: Plans::Comparison.new)
  end
end
