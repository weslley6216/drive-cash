module Notifications
  module Presenters
    class MaintenanceDue < Base
      private

      def title
        translate("title_#{data['status']}", item: category_label)
      end

      def body
        translate("body_#{data['status']}",
                  km:       delimited(data['km_until'].abs),
                  interval: delimited(data['interval_km']))
      end

      def icon = PhlexIcons::Lucide::Wrench

      def palette_key = data['status'] == 'overdue' ? :danger : :warning

      def path = vehicle_path(highlight: "maintenance_#{data['maintenance_id']}")

      def inline_action
        InlineAction.new(
          label: I18n.t('notifications.actions.mark_done'),
          path:  new_maintenance_mark_done_path(data['maintenance_id']),
          frame: 'modal'
        )
      end

      def category_label
        I18n.t("vehicle.maintenances.catalog.#{data['category']}")
      end

      def delimited(value)
        number_with_delimiter(value, delimiter: '.')
      end
    end
  end
end
