module Earnings
  class UpdateView < ApplicationView
    include TurboUpdateResponse

    def initialize(earning:, totals:, context: {}, detail: nil)
      @earning = earning
      @totals = totals
      @context = context || {}
      @detail = detail
    end

    def view_template
      render_turbo_streams(
        record:      @earning,
        edit_view:   Earnings::EditView,
        record_key:  :earning,
        detail:      @detail,
        detail_view: Dashboard::EarningsDetailView
      )
    end
  end
end
