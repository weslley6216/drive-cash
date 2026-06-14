module Chat
  module Summaries
    class Expense < Base
      def call
        category = I18n.t("activerecord.attributes.expense.categories.#{@params['category']}",
                          default: @params['category'].to_s.capitalize)
        vendor = @params['vendor'].present? ? " — #{@params['vendor']}" : ''
        base = I18n.t('chat.preview.expense',
                      amount:   format_currency(@params['amount']),
                      category: category,
                      vendor:   vendor,
                      date:     format_date(@params['date']))

        installments = InstallmentInfo.new(@params)
        return base unless installments.present?

        I18n.t('chat.preview.expense_installments',
               base:         base,
               installments: installments.count,
               period:       I18n.t("expenses.period_labels.#{installments.period}", default: installments.period))
      end
    end
  end
end
