module Chat
  class ExpensePersister
    def persist(payload)
      result = Ai::ExpenseFromChat.persist(payload)

      if result.success?
        PersistedResult.success(record: result.expenses.first, action: 'create_expense')
      else
        PersistedResult.failure(errors: result.expense.errors.full_messages)
      end
    end
  end
end
