module Goals
  module Achievements
    class BestDay < Base
      private

      def interpolations
        { value: format_currency_short(@raw[:value]), date: I18n.l(@raw[:date], format: :day_abbr) }
      end
    end
  end
end
