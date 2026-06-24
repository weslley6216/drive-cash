module Chat
  module Answers
    class BestMonth
      include Formatting

      def initialize(data)
        @data = data
      end

      def call
        return I18n.t('chat.answer.no_data') unless @data

        I18n.t('chat.answer.best_month',
               month: @data[:month],
               year:  @data[:year],
               value: format_currency(@data[:profit]))
      end
    end
  end
end
