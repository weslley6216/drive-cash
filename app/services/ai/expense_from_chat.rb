module Ai
  class ExpenseFromChat
    def self.persist(raw, user:)
      params = ChatExpenseParams.new(raw)
      attrs = params.attributes

      if params.installments >= 2
        return installments_period_error(attrs, user) unless Expense::INSTALLMENT_PERIODS.include?(params.period)

        return Expenses::InstallmentCreator.call(attrs, { repetitions: params.installments, period: params.period }, user: user)
      end

      persist_single(attrs, user)
    end

    class << self
      private

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
