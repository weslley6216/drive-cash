module Earnings
  class Creator
    Result = Data.define(:success?, :earning)

    def self.call(earning_params, user:)
      new(earning_params, user: user).call
    end

    def initialize(earning_params, user:)
      @earning_params = earning_params.to_h.stringify_keys.except('user_id')
      @user = user
    end

    def call
      earning = @user.earnings.new(@earning_params)
      if earning.save
        Result.new(success?: true, earning: earning)
      else
        Result.new(success?: false, earning: earning)
      end
    end
  end
end
