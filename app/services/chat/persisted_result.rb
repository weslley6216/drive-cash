module Chat
  PersistedResult = Struct.new(:success?, :record, :action, :errors, keyword_init: true) do
    def self.success(record:, action:)
      new(success?: true, record: record, action: action, errors: [])
    end

    def self.failure(errors:)
      new(success?: false, errors: errors)
    end
  end
end
