module Ai
  class ExpenseFromChat
    ATTRIBUTE_KEYS = %w[date amount category vendor description].freeze

    def self.persist(raw, user:)
      attrs_hash = coerce_hash(raw)

      installments = extract_installments_int(attrs_hash.delete('installments'))
      period = extract_period(attrs_hash.delete('installments_period'))
      attrs = attrs_hash.slice(*ATTRIBUTE_KEYS)

      if installments >= 2
        return installments_period_error(attrs, user) unless Expense::INSTALLMENT_PERIODS.include?(period)

        return Expenses::InstallmentCreator.call(attrs, { repetitions: installments, period: period }, user: user)
      end

      persist_single(attrs, user)
    end

    class << self
      private

      def coerce_hash(raw)
        case raw
        when ActionController::Parameters
          raw.permit(:date, :amount, :category, :vendor, :description,
                     :installments, :installments_period).to_h.stringify_keys
        when Hash then raw.stringify_keys.except('user_id')
        else {}
        end
      end

      def extract_installments_int(value)
        return 0 if value.nil?

        value.to_i
      end

      def extract_period(value)
        period_text = value.respond_to?(:to_s) ? value.to_s : ''
        period_text.presence || ''
      end

      def installments_period_error(attrs, user)
        expense = user.expenses.new(attrs.merge(paid: true))
        expense.errors.add(:base, I18n.t('expenses.installments.errors.invalid_period_for_installments'))

        Expenses::InstallmentCreator::Result.new(success?: false, expense: expense)
      end

      def persist_single(attrs, user)
        expense = user.expenses.new(attrs.merge(paid: true))
        return Expenses::InstallmentCreator::Result.new(success?: true, expenses: [expense]) if expense.save

        Expenses::InstallmentCreator::Result.new(success?: false, expense: expense)
      end
    end
  end
end
