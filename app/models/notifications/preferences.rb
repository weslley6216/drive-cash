module Notifications
  class Preferences
    def initialize(settings = {})
      @settings = settings.to_h.transform_keys(&:to_s).freeze
      freeze
    end

    def enabled?(kind)
      @settings[kind.to_s] != false
    end

    def disabled_kinds
      @settings.keys
    end

    def with(kind, enabled)
      kind = kind.to_s
      new_settings = @settings.dup
      enabled ? new_settings.delete(kind) : new_settings[kind] = false

      self.class.new(new_settings)
    end

    def to_h
      @settings.dup
    end
  end
end
