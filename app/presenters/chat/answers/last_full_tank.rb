module Chat
  module Answers
    class LastFullTank
      def initialize(data)
        @data = data
      end

      def call
        return I18n.t('chat.answer.no_full_tank') unless @data

        date = I18n.l(@data.date, format: :short)
        vendor = @data.vendor.presence || '?'
        I18n.t('chat.answer.last_full_tank', date: date, vendor: vendor)
      end
    end
  end
end
