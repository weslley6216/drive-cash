module DomainName
  module Presenters
    def self.present(raw)
      const_get(raw[:type].camelize).new(raw).call
    end

    class Base
      include Formatting

      I18N_SCOPE = 'domain_name.presenters'

      def initialize(raw)
        @raw = raw
      end

      def call
        { type: @raw[:type], title: title, description: description }
      end

      private

      def payload
        @raw[:payload]
      end

      def translate(key, **options)
        I18n.t("#{I18N_SCOPE}.#{@raw[:type]}.#{key}", **options)
      end
    end

    class FirstVariant < Base
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
