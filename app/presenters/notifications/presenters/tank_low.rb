module Notifications
  module Presenters
    class TankLow < Base
      private

      def icon = PhlexIcons::Lucide::Fuel

      def palette_key = :danger
    end
  end
end
