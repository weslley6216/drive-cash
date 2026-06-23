module Chat
  module Answers
    class Summary
      include Formatting

      def initialize(data)
        @data = data
      end

      def call
        return I18n.t('chat.answer.no_data') unless @data

        parts = [
          I18n.t('chat.answer.profit', value: format_currency(@data[:profit])),
          I18n.t('chat.answer.earnings', value: format_currency(@data[:earnings])),
          I18n.t('chat.answer.expenses', value: format_currency(@data[:expenses]))
        ]
        parts << I18n.t('chat.answer.margin', value: @data[:margin]) if @data[:margin]
        parts << I18n.t('chat.answer.per_km', value: format_currency(@data[:per_km])) if @data[:per_km]
        parts.join(' · ')
      end
    end
  end
end
