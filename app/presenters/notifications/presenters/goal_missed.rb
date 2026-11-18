module Notifications
  module Presenters
    class GoalMissed < Base
      def self.icon = PhlexIcons::Lucide::Target

      def self.palette_key = :attention

      private

      def title
        band = shortfall.near? ? 'near' : 'closed'
        translate("title.#{band}.#{data['kind']}", period: period_label.short)
      end

      def body
        translate('body', percent: shortfall.percent, current: format_currency(data['current']),
                           target: format_currency(data['target']))
      end

      def path = goal_outcome_path(data['goal_id'], data['period_start'])

      def shortfall
        Goals::Shortfall.new(target: data['target'].to_d, achieved: data['current'].to_d)
      end

      def period_label
        Goals::PeriodLabel.new(kind: data['kind'], period: Goal.period_for(data['kind'], Date.parse(data['period_start'])))
      end
    end
  end
end
