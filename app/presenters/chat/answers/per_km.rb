module Chat
  module Answers
    class PerKm
      include Formatting

      def initialize(data)
        @data = data
      end

      def call
        return I18n.t('chat.answer.no_data') unless @data

        I18n.t('chat.answer.per_km_value', value: format_currency(@data))
      end
    end
  end
end
