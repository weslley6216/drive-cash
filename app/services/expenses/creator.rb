module Expenses
  class Creator
    def self.call(expense_params, installment_params = {}, user:)
      new(expense_params, installment_params, user: user).call
    end

    def initialize(expense_params, installment_params, user:)
      @expense_params = expense_params.to_h.stringify_keys.except('user_id')
      @installment_params = installment_params.to_h.symbolize_keys
      @user = user
    end

    def call
      if should_create_installments?
        InstallmentCreator.call(@expense_params, @installment_params, user: @user)
      else
        create_single_expense
      end
    end

    private

    def should_create_installments?
      ActiveModel::Type::Boolean.new.cast(@installment_params[:repeat])
    end

    def create_single_expense
      expense = @user.expenses.new(@expense_params.reverse_merge('paid' => true))

      if expense.save
        InstallmentCreator::Result.success(expenses: [expense])
      else
        InstallmentCreator::Result.failure(expense: expense)
      end
    end
  end
end
