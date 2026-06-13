module Chat
  class EarningPersister
    ATTRIBUTE_KEYS = %i[date amount platform notes].freeze

    def persist(payload, user:)
      record = user.earnings.new(Payload.permit(payload, ATTRIBUTE_KEYS))

      if record.save
        PersistedResult.success(record: record, action: 'create_earning')
      else
        PersistedResult.failure(errors: record.errors.full_messages)
      end
    end
  end
end
