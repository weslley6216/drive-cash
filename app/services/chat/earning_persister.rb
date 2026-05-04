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
      when ActionController::Parameters then raw.permit(:date, :amount, :platform, :notes)
      when Hash then raw.slice('date', 'amount', 'platform', 'notes').merge(raw.slice(:date, :amount, :platform, :notes))
      else {}
      end
    end
  end
end
