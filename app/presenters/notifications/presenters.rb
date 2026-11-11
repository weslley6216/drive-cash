module Notifications
  module Presenters
    Row = Data.define(:notification, :title, :body, :icon, :palette_key, :path, :frame, :inline_action) do
      def destination(via) = via == 'inline' && inline_action ? inline_action.path : path
    end

    InlineAction = Data.define(:label, :path, :frame)

    def self.present(notification)
      const_get(notification.kind.camelize, false).new(notification).call
    end
  end
end
