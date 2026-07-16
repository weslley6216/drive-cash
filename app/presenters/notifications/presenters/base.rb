module Notifications
  module Presenters
    class Base
      include Formatting

      I18N_SCOPE = 'notifications.kinds'

      def initialize(notification)
        @notification = notification
      end

      def call
        Row.new(
          notification: @notification,
          title:        title,
          body:         body,
          icon:         icon,
          palette_key:  palette_key
        )
      end

      private

      def data = @notification.data

      def translate(key, **options)
        I18n.t("#{I18N_SCOPE}.#{@notification.kind}.#{key}", **options)
      end

      def title = translate('title')

      def body = translate('body')
    end
  end
end
