module Dashboard
  module Insights
    module Presenters
      class BestDay < Base
        private

        def title
          translate('title', value: format_currency(payload[:amount]))
        end

        def description
          translate('description', date: I18n.l(payload[:date], format: :default))
        end
      end
    end
  end
end
