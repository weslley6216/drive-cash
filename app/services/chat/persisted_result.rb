module Chat
  PersistedResult = Data.define(:success?, :record, :action, :errors) do
    def self.success(record:, action:)
      new(success?: true, record: record, action: action, errors: [])
    end

    def self.failure(errors:)
      new(success?: false, record: nil, action: nil, errors: errors)
    end
  end
end
