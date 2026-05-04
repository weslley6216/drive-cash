module Chat
  class RecordPersister
    def self.for(action)
      case action
      when 'create_expense' then ExpensePersister.new
      when 'create_earning' then EarningPersister.new
      else nil
      end
    end
  end

  PersistedResult = Struct.new(:success?, :record, :action, :errors, keyword_init: true) do
    def self.success(record:, action:)
      new(success?: true, record: record, action: action, errors: [])
    end

    def self.failure(errors:)
      new(success?: false, errors: errors)
    end
  end
end
