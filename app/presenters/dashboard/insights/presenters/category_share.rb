module Dashboard
  module Insights
    module Presenters
      class CategoryShare < Base
        private

        def title
          translate('title', category: payload[:category], pct: format_percentage(payload[:percent]))
        end

        def description
          translate('description',
                    value:  format_currency(payload[:amount]),
                    period: translate(payload[:month] ? 'period_monthly' : 'period_annual'))
        end
      end
    end
  end
end
