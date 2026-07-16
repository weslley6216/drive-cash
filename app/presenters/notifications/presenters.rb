module Notifications
  module Presenters
    Row = Data.define(:notification, :title, :body, :icon, :palette_key)

    def self.present(notification)
      const_get(notification.kind.camelize, false).new(notification).call
    end
  end
end
