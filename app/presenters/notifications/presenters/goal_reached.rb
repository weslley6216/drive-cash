module Notifications
  module Presenters
    class GoalReached < Base
      def self.icon = PhlexIcons::Lucide::Target

      def self.palette_key = :success

      private

      def title
        translate("title.#{data['kind']}")
      end

      def body
        translate('body', period: period_label.short, value: format_currency(data['current']))
      end

      def path = goal_outcome_path(data['goal_id'], data['period_start'])

      def period_label
        Goals::PeriodLabel.new(kind: data['kind'], period: Goal.period_for(data['kind'], Date.parse(data['period_start'])))
      end
    end
  end
end
