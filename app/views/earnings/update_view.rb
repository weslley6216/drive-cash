module Earnings
  class UpdateView < ApplicationView
    include TurboUpdateResponse

    def initialize(earning:, totals:, context: {}, totals_context: {})
      @earning = earning
      @totals = totals
      @context = context || {}
      @totals_context = totals_context || {}
    end

    def view_template
      render_turbo_streams(
        record: @earning,
        edit_view: Earnings::EditView,
        record_key: :earning,
        detail_service: Dashboard::EarningsDetailService,
        detail_view: Dashboard::EarningsDetailView
      )
    end
  end
end
