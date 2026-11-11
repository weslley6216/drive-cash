module Notifications
  module Presenters
    class Base
      include Formatting
      include Rails.application.routes.url_helpers

      I18N_SCOPE = 'notifications.kinds'

      def initialize(notification)
        @notification = notification
      end

      def call
        Row.new(
          notification:  @notification,
          title:         title,
          body:          body,
          icon:          icon,
          palette_key:   palette_key,
          path:          path,
          frame:         frame,
          inline_action: inline_action
        )
      end

      private

      def data = @notification.data

      def translate(key, **options)
        I18n.t("#{I18N_SCOPE}.#{@notification.kind}.#{key}", **options)
      end

      def title = translate('title')

      def body = translate('body')

      def icon = self.class.icon

      def palette_key = self.class.palette_key

      def frame = '_top'

      def inline_action = nil
    end
  end
end
