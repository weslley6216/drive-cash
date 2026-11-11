module Notifications
  module Presenters
    class TankLow < Base
      private

      def icon = PhlexIcons::Lucide::Fuel

      def palette_key = :danger

      def path = new_refueling_path

      def frame = 'modal'

      def inline_action
        InlineAction.new(label: I18n.t('notifications.actions.refuel'), path: new_refueling_path, frame: 'modal')
      end
    end
  end
end
