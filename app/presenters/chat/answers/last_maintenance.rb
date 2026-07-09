module Chat
  module Answers
    class LastMaintenance
      def initialize(data)
        @data = data
      end

      def call
        return I18n.t('chat.answer.no_data') unless @data

        category = I18n.t("vehicle.maintenances.catalog.#{@data.category}")
        "Última #{category}: #{@data.last_done_km} km"
      end
    end
  end
end
