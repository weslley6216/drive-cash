module Notifications
  module Presenters
    class LogReminder < Base
      def self.icon = PhlexIcons::Lucide::Calendar

      def self.palette_key = :neutral

      private

      def path = history_path(focus_day: empty_day.iso8601, highlight: "day-#{empty_day.iso8601}")

      def inline_action
        InlineAction.new(label: log_day_label(empty_day), path: new_record_path(date: empty_day), frame: '_top')
      end

      def empty_day = Date.parse(data['date']) - 1
    end
  end
end
