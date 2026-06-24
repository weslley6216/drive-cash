module Chat
  module Answers
    class BestDay
      include Formatting

      def initialize(data)
        @data = data
      end

      def call
        return I18n.t('chat.answer.no_data') unless @data

        day = I18n.l(@data[:date], format: :short)
        I18n.t('chat.answer.best_day', day: day, value: format_currency(@data[:amount]))
      end
    end
  end
end
