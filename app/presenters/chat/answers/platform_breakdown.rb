module Chat
  module Answers
    class PlatformBreakdown
      include Formatting

      def initialize(data)
        @data = data
      end

      def call
        return I18n.t('chat.answer.no_data') if @data.blank?

        @data.map { |row| "#{row[:label]}: #{format_currency(row[:amount])} (#{row[:percent].round(0)}%)" }.join(' · ')
      end
    end
  end
end
