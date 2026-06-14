module Chat
  module Summaries
    class Earning < Base
      def call
        platform = I18n.t("activerecord.attributes.earning.platforms.#{@params['platform']}",
                          default: @params['platform'].to_s.capitalize)
        I18n.t('chat.preview.earning',
               amount: format_currency(@params['amount']),
               platform: platform,
               date: format_date(@params['date']))
      end
    end
  end
end
