module Chat
  module Answers
    class VendorEfficiency
      include Formatting

      def initialize(data)
        @data = data
      end

      def call
        return I18n.t('chat.answer.vendor_efficiency_no_data') unless @data

        I18n.t('chat.answer.vendor_best',
               vendor:  @data.winner,
               kml:     @data.winner_kml.round(2),
               savings: format_currency(@data.savings))
      end
    end
  end
end
