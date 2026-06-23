module Chat
  module Answers
    class PerTrip
      include Formatting

      def initialize(data)
        @data = data
      end

      def call
        return I18n.t('chat.answer.no_data') unless @data && @data > 0

        I18n.t('chat.answer.per_trip_value', value: format_currency(@data))
      end
    end
  end
end
