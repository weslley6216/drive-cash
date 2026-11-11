module Notifications
  module PreferenceRows
    Row = Data.define(:kind, :title, :rule, :icon, :palette_key, :enabled)

    def self.call(settings)
      Registry::KINDS.map { |kind| build_row(kind, settings) }
    end

    def self.build_row(kind, settings)
      presenter = Presenters.const_get(kind.camelize, false)

      Row.new(
        kind:        kind,
        title:       I18n.t("notifications.preferences.kinds.#{kind}.title"),
        rule:        I18n.t("notifications.preferences.kinds.#{kind}.when"),
        icon:        presenter.icon,
        palette_key: presenter.palette_key,
        enabled:     settings.enabled?(kind)
      )
    end
    private_class_method :build_row
  end
end
