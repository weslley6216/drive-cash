module Chat
  module Answers
    class WorstPlatform
      include Formatting

      def initialize(data)
        @data = data
      end

      def call
        return I18n.t('chat.answer.no_data') unless @data

        I18n.t('chat.answer.worst_platform',
               platform: @data[:platform],
               per_trip: format_currency(@data[:per_trip]))
      end
    end
  end
end
