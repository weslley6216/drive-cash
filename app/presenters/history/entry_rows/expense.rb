module History
  module EntryRows
    class Expense < Base
      def amount_color = 'text-red-700'
      def sign = '−'
      def edit_route = :edit_expense_path
      def edit_label = I18n.t('history.index.edit.expense')
      def category = @record.category

      def label_text
        I18n.t("activerecord.attributes.expense.categories.#{@record.category}")
      end

      def description_text
        @record.vendor.presence || @record.description.to_s
      end

      def unpaid? = !@record.paid?

      def status_key = unpaid? ? :pending : :paid
    end
  end
end
