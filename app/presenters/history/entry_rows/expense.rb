module History
  module EntryRows
    class Expense < Base
      def icon = PhlexIcons::Lucide::Receipt
      def icon_bg = 'bg-red-50'
      def icon_color = 'text-red-600'
      def amount_color = 'text-red-700'
      def sign = '−'
      def edit_route = :edit_expense_path
      def edit_label = I18n.t('history.index.edit.expense')

      def label_text
        I18n.t("activerecord.attributes.expense.categories.#{@record.category}")
      end

      def description_text
        @record.vendor.presence || @record.description.to_s
      end

      def unpaid? = !@record.paid?
    end
  end
end
