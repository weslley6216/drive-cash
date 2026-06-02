module Chat
  class EarningPersister
    def persist(payload)
      attrs = coerce_params(payload)
      record = Earning.new(attrs)

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
        raw.permit(:date, :amount, :platform, :notes, :user_id)
      when Hash
        raw.slice('date', 'amount', 'platform', 'notes', 'user_id')
           .merge(raw.slice(:date, :amount, :platform, :notes, :user_id))
      else {}
      end
    end
  end
end
