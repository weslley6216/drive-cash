module Expenses
  class InstallmentCreator
    Result = Struct.new(:success?, :expenses, :expense, keyword_init: true)

    def self.call(expense_attributes, installment_attributes)
      new(expense_attributes, installment_attributes).call
    end

    def initialize(expense_attributes, installment_attributes)
      @base_attrs = expense_attributes.to_h.stringify_keys
      @installment_attrs = installment_attributes.to_h.symbolize_keys
    end

    def call
      plan = build_plan
      return invalid_plan_failure unless plan.valid?

      expenses = persist_installments(plan)
      Result.new(success?: true, expenses: expenses)
    rescue ActiveRecord::RecordInvalid => e
      record_invalid_failure(e)
    end

    private

    def build_plan
      InstallmentPlan.new(
        total_amount: @base_attrs['amount'],
        start_date: @base_attrs['date'],
        period: @installment_attrs[:period],
        repetitions: @installment_attrs[:repetitions].to_i
      )
    end

    def persist_installments(plan)
      expenses = []

      Expense.transaction do
        plan.count.times do |index|
          expenses << create_installment(plan, index)
        end
      end

      expenses
    end

    def create_installment(plan, index)
      Expense.create!(
        @base_attrs.merge(plan.installment_attributes(index))
      )
    end

    def invalid_plan_failure
      expense = Expense.new(@base_attrs)
      expense.errors.add(:base, I18n.t('expenses.installments.errors.invalid_repeat'))
      Result.new(success?: false, expense: expense)
    end

    def record_invalid_failure(exception)
      expense = Expense.new(@base_attrs)
      expense.errors.add(:base, exception.record.errors.full_messages.to_sentence)
      Result.new(success?: false, expense: expense)
    end
  end
end
