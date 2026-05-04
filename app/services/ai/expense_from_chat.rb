module Ai
  class ExpenseFromChat
    ATTRIBUTE_KEYS = %w[date amount category vendor description].freeze

    def self.persist(raw)
      h = coerce_hash(raw)

      installments = extract_installments_int(h.delete('installments'))
      period = extract_period(h.delete('installments_period'))
      attrs = h.slice(*ATTRIBUTE_KEYS)

      if installments >= 2
        return installments_period_error(attrs) unless Expense::INSTALLMENT_PERIODS.include?(period)

        return Expenses::InstallmentCreator.call(attrs, { repetitions: installments, period: period })
      end

      persist_single(attrs)
    end

    class << self
      private

      def coerce_hash(raw)
        case raw
        when ActionController::Parameters then raw.permit!.to_unsafe_h
        when Hash then raw.stringify_keys
        else {}
        end
      end

      def extract_installments_int(value)
        return 0 if value.nil?

        value.to_i
      end

      def extract_period(value)
        val = value.respond_to?(:to_s) ? value.to_s : ''
        val.presence || ''
      end

      def installments_period_error(attrs)
        expense = Expense.new(attrs.merge(paid: true))
        expense.errors.add(:base, I18n.t('expenses.installments.errors.invalid_period_for_installments'))

        Expenses::InstallmentCreator::Result.new(success?: false, expense: expense)
      end

      def persist_single(attrs)
        expense = Expense.new(attrs.merge(paid: true))
        return Expenses::InstallmentCreator::Result.new(success?: true, expenses: [expense]) if expense.save

        Expenses::InstallmentCreator::Result.new(success?: false, expense: expense)
      end
    end
  end
end
