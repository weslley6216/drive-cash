module Notifications
  module Presenters
    class LogReminder < Base
      def self.icon = PhlexIcons::Lucide::Calendar

      def self.palette_key = :neutral

      private

      def path = new_record_path(date: Date.parse(data['date']) - 1)
    end
  end
end
