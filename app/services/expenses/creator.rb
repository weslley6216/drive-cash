module Expenses
  class Creator
    def self.call(expense_params, installment_params = {}, refueling_params = {}, user:)
      new(expense_params, installment_params, refueling_params, user: user).call
    end

    def initialize(expense_params, installment_params, refueling_params, user:)
      @expense_params = expense_params.to_h.stringify_keys.except('user_id')
      @installment_params = installment_params.to_h.symbolize_keys
      @refueling_params = refueling_params.to_h.symbolize_keys
      @user = user
    end

    def call
      result = nil

      Expense.transaction do
        result = should_create_installments? ? create_installments : create_single_expense
        raise ActiveRecord::Rollback unless result.success?

        refueling_result = create_refueling(result.expenses.first)
        next if refueling_result.success?

        result = refueling_failure(result.expenses.first, refueling_result.refueling)
        raise ActiveRecord::Rollback
      end

      result
    end

    private

    def create_installments
      InstallmentCreator.call(@expense_params, @installment_params, user: @user)
    end

    def create_single_expense
      expense = @user.expenses.new(@expense_params.reverse_merge('paid' => true))

      if expense.save
        InstallmentCreator::Result.success(expenses: [expense])
      else
        InstallmentCreator::Result.failure(expense: expense)
      end
    end

    def create_refueling(expense)
      Refuelings::CreatorFromExpense.call(
        expense:     expense,
        liters:      @refueling_params[:liters],
        odometer_km: @refueling_params[:odometer_km],
        full_tank:   @refueling_params.fetch(:full_tank, true)
      )
    end

    def refueling_failure(expense, refueling)
      expense.errors.add(:base, refueling.errors.full_messages.to_sentence)
      InstallmentCreator::Result.failure(expense: expense)
    end

    def should_create_installments?
      ActiveModel::Type::Boolean.new.cast(@installment_params[:repeat])
    end
  end
end
