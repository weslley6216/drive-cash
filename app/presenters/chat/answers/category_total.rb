module Chat
  module Answers
    class CategoryTotal
      include Formatting

      def initialize(data)
        @data = data
      end

      def call
        return I18n.t('chat.answer.no_data') unless @data

        I18n.t('chat.answer.category_total',
               category: I18n.t("activerecord.attributes.expense.categories.#{@data[:category]}"),
               value:    format_currency(@data[:total]))
      end
    end
  end
end
