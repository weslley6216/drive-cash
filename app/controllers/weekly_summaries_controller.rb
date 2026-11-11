class WeeklySummariesController < ApplicationController
  def show
    summary = WeeklySummaries::Builder.for(user: current_user, week_start: params[:week_start]).call
    render WeeklySummaries::ShowView.new(summary: summary)
  end
end
