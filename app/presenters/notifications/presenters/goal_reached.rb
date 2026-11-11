module Notifications
  module Presenters
    class GoalReached < Base
      def self.icon = PhlexIcons::Lucide::Target

      def self.palette_key = :success

      private

      def body
        translate('body', month: month_label, value: format_currency(data['current']))
      end

      def path = goals_path

      def month_label
        I18n.l(Date.parse(data['month']), format: '%B').capitalize
      end
    end
  end
end
