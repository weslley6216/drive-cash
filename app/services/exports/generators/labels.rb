module Exports
  module Generators
    module Labels
      private

      def platform_label(key)
        I18n.t("activerecord.attributes.earning.platforms.#{key}")
      end

      def expense_category_label(key)
        I18n.t("activerecord.attributes.expense.categories.#{key}")
      end

      def maintenance_category_label(key)
        I18n.t("vehicle.maintenances.catalog.#{key}")
      end
    end
  end
end
