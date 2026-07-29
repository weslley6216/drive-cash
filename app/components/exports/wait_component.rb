module Exports
  class WaitComponent < ApplicationComponent
    TIMEOUT_MS = 20_000

    def initialize(export:)
      @export = export
    end

    def view_template
      div(id:   'export-wait',
          data: {
            controller:                  'export-wait',
            export_wait_export_id_value: @export.id,
            export_wait_timeout_value:   TIMEOUT_MS
          }) do
        download_link
        hint
      end
    end

    private

    def download_link
      link_to(t('exports.download'), export_path(@export),
              class: 'hidden',
              data:  { export_wait_target: 'download', turbo: false })
    end

    def hint
      div(class: 'hidden rounded-2xl bg-blue-50 border border-blue-200 p-3.5 mb-2.5 flex items-start gap-2.5',
          data:  { export_wait_target: 'hint' }) do
        render PhlexIcons::Lucide::Clock.new(class: 'w-[17px] h-[17px] text-blue-600 flex-shrink-0 mt-0.5')
        p(class: 'text-xs text-blue-800 leading-snug') { t('exports.wait.still_running') }
      end
    end
  end
end
