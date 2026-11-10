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
          payload: { category: top[:label], percent: top[:percent], amount: top[:amount].to_f, month: @context.month }
        }
      end
    end
  end
end
