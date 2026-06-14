module Dashboard
  module Insights
    module Presenters
      class CategorySpike < Base
        private

        def title
          translate('title', category: payload[:category], pct: payload[:pct])
        end

        def description
          if payload[:mode] == :monthly
            translate('description_monthly',
                      category:        payload[:category],
                      pct:             payload[:pct],
                      value:           format_currency(payload[:amount]),
                      period:          I18n.t('date.month_names')[payload[:month]],
                      previous_period: I18n.t('date.month_names')[payload[:previous_month]])
          else
            translate('description_annual',
                      category:      payload[:category],
                      pct:           payload[:pct],
                      value:         format_currency(payload[:amount]),
                      previous_year: payload[:previous_year])
          end
        end
      end
    end
  end
end
