module Dashboard
  module Insights
    module Presenters
      def self.present(raw)
        const_get(raw[:type].camelize).new(raw).call
      end
    end
  end
end
