module Dashboard
  module Insights
    module Presenters
      class Base
        include Formatting

        I18N_SCOPE = 'analysis.show_view.insights'

        def initialize(raw)
          @raw = raw
        end

        def call
          {
            type:        @raw[:type],
            severity:    @raw[:severity],
            title:       title,
            description: description
          }
        end

        private

        def payload
          @raw[:payload]
        end

        def translate(key, **options)
          I18n.t("#{I18N_SCOPE}.#{@raw[:type]}.#{key}", **options)
        end
      end
    end
  end
end
