module Notifications
  class PreferenceUpdater
    Result = Data.define(:kind, :enabled, :success) do
      def success? = success
    end

    def self.call(user:, kind:, enabled:)
      new(user: user, kind: kind, enabled: enabled).call
    end

    def initialize(user:, kind:, enabled:)
      @user = user
      @kind = kind
      @enabled = ActiveModel::Type::Boolean.new.cast(enabled)
    end

    def call
      success = @user.update(notification_settings: @user.notification_settings.with(@kind, @enabled))

      Result.new(kind: @kind, enabled: @enabled, success: success)
    end
  end
end
