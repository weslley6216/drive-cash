module Notifications
  module Presenters
    class GoalReached < Base
      private

      def body
        translate('body', month: month_label, value: format_currency(data['current']))
      end

      def icon = PhlexIcons::Lucide::Target

      def palette_key = :success

      def month_label
        I18n.l(Date.parse(data['month']), format: '%B').capitalize
      end
    end
  end
end
