module Chat
  module Summaries
    class Base
      include Formatting

      def initialize(params)
        @params = params || {}
      end

      private

      def format_date(date_str)
        Date.parse(date_str.to_s).strftime('%d/%m/%Y')
      rescue ArgumentError
        date_str.to_s
      end
    end
  end
end
