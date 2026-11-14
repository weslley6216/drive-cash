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
            title:       title,
            description: description,
            link:        link
          }
        end

        private

        def payload
          @raw[:payload]
        end

        def translate(key, **options)
          I18n.t("#{I18N_SCOPE}.#{@raw[:type]}.#{key}", **options)
        end

        def link
          nil
        end
      end
    end
  end
end
