module Notifications
  module Presenters
    class WeeklySummary < Base
      private

      def body
        translate('body', value: format_currency(data['profit']), trips: I18n.t('common.trips', count: data['trips']))
      end

      def icon = PhlexIcons::Lucide::ChartColumn

      def palette_key = :info
    end
  end
end
