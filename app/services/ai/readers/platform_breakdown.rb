module Ai
  module Readers
    class PlatformBreakdown
      def initialize(params, user:)
        @params = params
        @user = user
      end

      def call
        year = @params['year']&.to_i || Date.current.year
        month = @params['month']&.to_i.presence

        Dashboard::PlatformBreakdownService.new(year: year, month: month, user: @user).call
      end
    end
  end
end
