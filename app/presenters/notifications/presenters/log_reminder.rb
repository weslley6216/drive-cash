module Notifications
  module Presenters
    class LogReminder < Base
      private

      def icon = PhlexIcons::Lucide::Calendar

      def palette_key = :neutral
    end
  end
end
