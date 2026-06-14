module Earnings
  class CreateView < ApplicationView
    include TurboCreateResponse

    def initialize(earning:, totals:, context: {})
      @earning = earning
      @totals = totals
      @context = context || {}
    end

    def view_template
      render_turbo_streams(record: @earning, new_view: Earnings::NewView, record_key: :earning)
    end
  end
end
