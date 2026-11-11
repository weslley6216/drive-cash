module Notifications
  module Presenters
    class LogReminder < Base
      private

      def icon = PhlexIcons::Lucide::Calendar

      def palette_key = :neutral

      def path = new_record_path(date: Date.parse(data['date']) - 1)
    end
  end
end
