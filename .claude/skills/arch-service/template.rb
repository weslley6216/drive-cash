module DomainName
  class Creator
    Result = Data.define(:success?, :record)

    def self.call(record_params, user:)
      new(record_params, user: user).call
    end

    def initialize(record_params, user:)
      @record_params = record_params.to_h.stringify_keys.except('user_id')
      @user = user
    end

    def call
      record = @user.records.new(@record_params)

      if record.save
        Result.new(success?: true, record: record)
      else
        Result.new(success?: false, record: record)
      end
    end
  end
end
