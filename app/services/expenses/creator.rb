module Expenses
  class Creator
    def self.call(expense_params, installment_params = {})
      new(expense_params, installment_params).call
    end

    def initialize(expense_params, installment_params)
      @expense_params = expense_params.to_h.stringify_keys
      @installment_params = installment_params.to_h.symbolize_keys
    end

    def call
      if should_create_installments?
        InstallmentCreator.call(@expense_params, @installment_params)
      else
        create_single_expense
      end
    end

    private

    def should_create_installments?
      ActiveModel::Type::Boolean.new.cast(@installment_params[:repeat])
    end

    def create_single_expense
      expense = Expense.new(@expense_params.reverse_merge('paid' => true))

      if expense.save
        InstallmentCreator::Result.new(success?: true, expenses: [expense])
      else
        InstallmentCreator::Result.new(success?: false, expense: expense)
      end
    end
  end
end
