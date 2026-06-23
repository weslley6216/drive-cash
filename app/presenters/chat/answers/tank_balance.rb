module Chat
  module Answers
    class TankBalance
      include Formatting

      def initialize(data)
        @data = data
      end

      def call
        return I18n.t('chat.answer.no_data') unless @data && @data[:balance].to_f > 0

        pct = @data[:full].to_f > 0 ? ((@data[:balance].to_f / @data[:full].to_f) * 100).round(0) : 0
        I18n.t('chat.answer.tank_balance', balance: format_currency(@data[:balance]), pct: pct)
      end
    end
  end
end
