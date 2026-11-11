module Notifications
  class PreferenceRowComponent < ApplicationComponent
    include Phlex::Rails::Helpers::FormWith

    def initialize(row:, first:)
      @row = row
      @first = first
    end

    def view_template
      div(class: row_classes) do
        render IconTileComponent.new(icon: @row.icon, palette_key: @row.palette_key, dimmed: !@row.enabled)
        content
        toggle
      end
    end

    private

    def row_classes
      class_names('flex items-start gap-3 px-4 py-3.5', ('border-t border-slate-100' unless @first))
    end

    def content
      div(class: 'flex-1 min-w-0') do
        p(class: title_classes) { @row.title }
        p(class: 'text-xs text-slate-500 mt-0.5 leading-snug') { @row.rule }
      end
    end

    def title_classes
      class_names('text-sm font-semibold', @row.enabled ? 'text-slate-800' : 'text-slate-500')
    end

    def toggle
      div(class: 'pt-1.5') do
        form_with(url: notification_preferences_path, method: :patch, data: { controller: 'auto-submit' }) do
          input(type: 'hidden', name: 'kind', value: @row.kind)
          input(type: 'hidden', name: 'enabled', value: 'false')
          toggle_control
        end
      end
    end

    def toggle_control
      label(class: 'relative w-11 h-6 rounded-full flex-shrink-0 block') do
        input(
          type:    'checkbox',
          name:    'enabled',
          value:   'true',
          checked: @row.enabled,
          class:   'sr-only peer',
          aria:    { label: @row.title },
          data:    { action: 'change->auto-submit#submit' }
        )
        span(class: 'absolute inset-0 rounded-full transition bg-slate-300 peer-checked:bg-blue-600 ' \
                     'peer-focus-visible:ring-2 peer-focus-visible:ring-blue-400 peer-focus-visible:ring-offset-2')
        span(class: 'absolute top-0.5 left-0.5 w-5 h-5 rounded-full bg-white shadow transition peer-checked:left-[22px]')
      end
    end
  end
end
