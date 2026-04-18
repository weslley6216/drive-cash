module Expenses
  class UpdateView < ApplicationView
    include TurboUpdateResponse

    def initialize(expense:, totals:, context: {}, totals_context: {})
      @expense = expense
      @totals = totals
      @context = context || {}
      @totals_context = totals_context || {}
    end

    def view_template
      render_turbo_streams(
        record: @expense,
        edit_view: Expenses::EditView,
        record_key: :expense,
        detail_service: Dashboard::ExpensesDetailService,
        detail_view: Dashboard::ExpensesDetailView
      )
    end
  end
end
