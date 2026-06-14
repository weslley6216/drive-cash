module Dashboard
  module Insights
    module Presenters
      class WorstPlatform < Base
        private

        def title
          translate('title', platform: payload[:platform])
        end

        def description
          translate('description', platform: payload[:platform], value: format_currency(payload[:per_trip]))
        end
      end
    end
  end
end
