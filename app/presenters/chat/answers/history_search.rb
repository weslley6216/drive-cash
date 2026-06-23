module Chat
  module Answers
    class HistorySearch
      def initialize(data)
        @data = data
      end

      def call
        return I18n.t('chat.answer.no_data') unless @data

        term = @data[:term]
        count = @data[:earnings].size + @data[:expenses].size

        if count.zero?
          I18n.t('chat.answer.history_empty', term: term)
        else
          I18n.t('chat.answer.history_found', count: count, term: term)
        end
      end
    end
  end
end
