module Notifications
  module Presenters
    Row = Data.define(:notification, :title, :body, :icon, :palette_key)

    def self.present(notification)
      const_get(notification.kind.camelize).new(notification).call
    end
  end
end
