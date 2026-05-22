module Chat
  class RecordPersister
    class NullPersister
      def persist(_payload)
        PersistedResult.failure(errors: [I18n.t('chat.errors.unknown_action')])
      end
    end

    def self.for(action)
      case action
      when 'create_expense' then ExpensePersister.new
      when 'create_earning' then EarningPersister.new
      else NullPersister.new
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
