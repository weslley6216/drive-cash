module Goals
  module Achievements
    class Base
      include Formatting

      def initialize(raw)
        @raw = raw
      end

      def call
        {
          type:  @raw[:type],
          short: translate('short', **interpolations),
          long:  translate('long', **interpolations)
        }
      end

      private

      def translate(key, **options)
        I18n.t("goals.index.achievements.#{@raw[:type]}.#{key}", **options)
      end
    end
  end
end
