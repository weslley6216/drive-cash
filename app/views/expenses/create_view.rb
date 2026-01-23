# app/views/expenses/create_view.rb
module Expenses
  class CreateView < ApplicationView
    def initialize(expense:, totals:, context: {})
      @expense = expense
      @totals = totals
      @context = context || {}
    end

    def view_template
      if @expense.persisted? && @totals
        raw turbo_stream.update('modal', '')
        raw turbo_stream.replace('stats_grid') {
          render StatsGridComponent.new(totals: @totals)
        }
      else
        raw turbo_stream.replace('modal') {
          render Expenses::NewView.new(expense: @expense, context: @context)
        }
      end

      raw turbo_stream.update('flash') {
        render FlashComponent.new(flash: helpers.flash)
      }
    end
  end
end
