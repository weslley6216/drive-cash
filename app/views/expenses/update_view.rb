module Expenses
  class UpdateView < ApplicationView
    include TurboUpdateResponse

    def initialize(expense:, totals:, context: {}, detail: nil)
      @expense = expense
      @totals = totals
      @context = context || {}
      @detail = detail
    end

    def view_template
      render_turbo_streams(
        record: @expense,
        edit_view: Expenses::EditView,
        record_key: :expense,
        detail: @detail,
        detail_view: Dashboard::ExpensesDetailView
      )
    end
  end
end
