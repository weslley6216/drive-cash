module Expenses
  class CreateView < ApplicationView
    include TurboCreateResponse

    def initialize(expense:, totals:, context: {}, totals_context: {})
      @expense = expense
      @totals = totals
      @context = context || {}
    end

    def view_template
      render_turbo_streams(record: @expense, new_view: Expenses::NewView, record_key: :expense)
    end
  end
end
