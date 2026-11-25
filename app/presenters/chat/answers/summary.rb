module Chat
  module Answers
    class Summary
      Card = Data.define(:year, :month, :profit, :earnings, :expenses, :profit_change, :best_day_on, :best_day_amount)

      def initialize(data)
        @data = data
      end

      def call
        return I18n.t('chat.answer.no_data') unless @data

        Card.new(
          year:            @data[:year],
          month:           @data[:month],
          profit:          @data[:profit],
          earnings:        @data[:earnings],
          expenses:        @data[:expenses],
          profit_change:   @data[:profit_change],
          best_day_on:     @data[:best_day]&.dig(:date)&.iso8601,
          best_day_amount: @data[:best_day]&.dig(:amount)
        )
      end
    end
  end
end
