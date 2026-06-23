module Chat
  class ExpensePersister
    def persist(payload, user:)
      enriched = enrich_fuel_vendor(payload, user: user)
      result = Ai::ExpenseFromChat.persist(enriched, user: user)

      if result.success?
        PersistedResult.success(record: result.expenses.first, action: 'create_expense')
      else
        PersistedResult.failure(errors: result.expense.errors.full_messages)
      end
    end

    private

    def enrich_fuel_vendor(payload, user:)
      return payload unless payload['category'].to_s == 'fuel' && payload['vendor'].blank?

      vendor = Vehicles::ActiveTankVendor.new(user: user).call
      return payload unless vendor

      payload.merge('vendor' => vendor)
    end
  end
end
