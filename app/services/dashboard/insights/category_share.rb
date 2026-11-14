module Dashboard
  module Insights
    class CategoryShare
      def initialize(context)
        @context = context
      end

      def call
        top = @context.categories.first
        return nil if top.nil?

        {
          type:    'category_share',
          payload: { category_id: top[:id], category: top[:label], percent: top[:percent], amount: top[:amount].to_f, year: @context.year, month: @context.month }
        }
      end
    end
  end
end
