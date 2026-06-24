module Chat
  module Answers
    class MarginDrop
      def initialize(data)
        @data = data
      end

      def call
        return I18n.t('chat.answer.no_data') unless @data

        I18n.t('chat.answer.margin_drop', pp: @data[:pp], current: @data[:current_margin])
      end
    end
  end
end
