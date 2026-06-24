module Chat
  module Answers
    class UnpaidExpenses
      include Formatting

      def initialize(data)
        @data = data
      end

      def call
        return I18n.t('chat.answer.no_data') unless @data.is_a?(Array)
        return I18n.t('chat.answer.no_data') if @data.empty?

        total = @data.sum { |expense| expense.amount.to_f }
        count = @data.size
        "Você tem #{count} conta(s) a pagar: #{format_currency(total)}"
      end
    end
  end
end
