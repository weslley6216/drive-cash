module Notifications
  module Presenters
    class TankLow < Base
      def self.icon = PhlexIcons::Lucide::Fuel

      def self.palette_key = :danger

      private

      def path = vehicle_path(highlight: 'vehicle_tank')

      def inline_action
        InlineAction.new(label: I18n.t('notifications.actions.refuel'), path: new_refueling_path, frame: 'modal')
      end
    end
  end
end
