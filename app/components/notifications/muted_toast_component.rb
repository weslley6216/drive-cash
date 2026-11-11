module Notifications
  class MutedToastComponent < ApplicationComponent
    include Phlex::Rails::Helpers::ButtonTo

    def initialize(payload:)
      @payload = payload
    end

    def view_template
      render ToastShellComponent.new do
        render PhlexIcons::Lucide::Bell.new(class: 'w-4 h-4 text-slate-400 flex-shrink-0')
        p(class: 'text-[13px] leading-snug flex-1') { message }
        button_to(t('notifications.muted.undo'), notification_preferences_path, method: :patch,
                  params: { kind: kind, enabled: true }, class: 'text-xs font-semibold text-blue-300')
      end
    end

    private

    def kind = @payload['kind']

    def message = t('notifications.muted.toast', kind: t("notifications.preferences.kinds.#{kind}.title"))
  end
end
