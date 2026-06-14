module History
  module EntryRows
    class Earning < Base
      def icon = PhlexIcons::Lucide::Truck
      def icon_bg = 'bg-emerald-50'
      def icon_color = 'text-emerald-600'
      def amount_color = 'text-emerald-700'
      def sign = '+'
      def edit_route = :edit_earning_path
      def edit_label = I18n.t('history.index.edit.earning')

      def label_text
        I18n.t("activerecord.attributes.earning.platforms.#{@record.platform}")
      end

      def description_text
        @record.notes.presence || I18n.t('common.trips', count: @record.trips_count)
      end
    end
  end
end
