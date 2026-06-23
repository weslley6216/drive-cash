module Chat
  module Summaries
    class Goal < Base
      def call
        kind = I18n.t("activerecord.attributes.goal.kinds.#{@params['kind']}",
                      default: @params['kind'].to_s)
        metric = @params['metric'] == 'earnings' ? 'ganhos' : 'lucro'
        I18n.t('chat.preview.goal',
               target: format_currency(@params['target_amount']),
               kind:   kind,
               metric: metric)
      end
    end
  end
end
