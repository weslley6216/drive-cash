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

      def category_label
        I18n.t("vehicle.maintenances.catalog.#{data['category']}")
      end

      def delimited(value)
        number_with_delimiter(value, delimiter: '.')
      end
    end
  end
end
