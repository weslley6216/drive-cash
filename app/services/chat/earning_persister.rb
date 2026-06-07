module Chat
  class EarningPersister
    def persist(payload, user:)
      record = user.earnings.new(coerce_params(payload))

      if record.save
        PersistedResult.success(record: record, action: 'create_earning')
      else
        PersistedResult.failure(errors: record.errors.full_messages)
      end
    end

    private

    def coerce_params(raw)
      case raw
      when ActionController::Parameters
        raw.permit(:date, :amount, :platform, :notes)
      when Hash
        raw.slice('date', 'amount', 'platform', 'notes')
      else
        {}
      end
    end
  end
end
