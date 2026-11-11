module Notifications
  module Presenters
    class WeeklySummary < Base
      def self.icon = PhlexIcons::Lucide::ChartColumn

      def self.palette_key = :info

      private

      def body
        translate('body', value: format_currency(data['profit']), trips: I18n.t('common.trips', count: data['trips']))
      end

      def path = weekly_summary_path(data['week_start'])
    end
  end
end
