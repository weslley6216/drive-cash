module Dashboard
  module Insights
    module Presenters
      class MarginDrop < Base
        private

        def title
          translate('title', pp: payload[:pp])
        end

        def description
          translate('description', value: payload[:current_margin])
        end
      end
    end
  end
end
