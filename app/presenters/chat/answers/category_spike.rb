module Chat
  module Answers
    class CategorySpike
      include Formatting

      def initialize(data)
        @data = data
      end

      def call
        return I18n.t('chat.answer.no_data') unless @data

        I18n.t('chat.answer.category_spike',
               category: @data[:category],
               pct:      @data[:pct].round(0),
               amount:   format_currency(@data[:amount]))
      end
    end
  end
end
