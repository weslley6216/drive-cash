module Notifications
  module Presenters
    class WeeklySummary < Base
      private

      def body
        translate('body', value: format_currency(data['profit']), trips: I18n.t('common.trips', count: data['trips']))
      end

      def icon = PhlexIcons::Lucide::ChartColumn

      def palette_key = :info

      def path
        week_start = Date.parse(data['week_start'])
        analysis_path(year: week_start.year, month: week_start.month)
      end
    end
  end
end
