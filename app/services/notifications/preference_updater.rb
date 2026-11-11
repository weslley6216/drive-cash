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
      success = known_kind? && save_preferences

      Result.new(kind: @kind, enabled: @enabled, success: success)
    end

    private

    def known_kind?
      Registry::KINDS.include?(@kind)
    end

    def save_preferences
      @user.notification_settings = @user.notification_settings.with(@kind, @enabled)
      @user.update_column(:notification_preferences, @user.notification_preferences)
    end
  end
end
