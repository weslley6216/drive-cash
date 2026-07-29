module Exports
  class RecentRowView < ApplicationView
    FRAME_CLASSES = 'block border-b border-slate-100 last:border-b-0'.freeze

    def initialize(export:)
      @export = export
    end

    def view_template
      turbo_frame_tag("export_#{@export.id}", class: FRAME_CLASSES, **frame_attrs) do
        if @export.status_failed?
          failed_row
        else
          linked_row
        end
      end
    end

    private

    def settled? = @export.status_done? || @export.status_failed?

    def settled_data
      return {} unless settled?

      { export_row_poll_target: 'settled', export_status: @export.status }
    end

    def poll_window
      @poll_window ||= Exports::PollWindow.new
    end

    def frame_attrs
      return {} if settled?

      {
        src:  helpers.row_export_path(@export),
        data: {
          controller:                         'export-row-poll',
          export_row_poll_interval_value:     poll_window.interval_ms,
          export_row_poll_max_attempts_value: poll_window.max_attempts,
          export_row_poll_export_id_value:    @export.id
        }
      }
    end

    def row_classes = 'flex items-center gap-3 px-4 py-3'

    def linked_row
      link_to(export_path(@export), class: row_classes, data: { turbo: false, **settled_data }) do
        icon
        info
        span(class: 'text-slate-400') { render PhlexIcons::Lucide::Download.new(class: 'w-[18px] h-[18px]') }
      end
    end

    def failed_row
      div(class: row_classes, data: settled_data) do
        icon
        info
      end
    end

    def icon
      div(class: 'w-9 h-9 rounded-lg bg-slate-100 text-slate-500 flex items-center justify-center flex-shrink-0') do
        render PhlexIcons::Lucide::FileText.new(class: 'w-[17px] h-[17px]')
      end
    end

    def info
      div(class: 'flex-1 min-w-0') do
        p(class: 'text-sm font-medium text-slate-800 truncate') { "DriveCash · #{Exports::RecentsName.new(@export).call}" }
        p(class: 'text-xs text-slate-500') { meta }
      end
    end

    def meta
      [@export.format.upcase, size_or_status, I18n.l(@export.created_at, format: :short)].compact.join(' · ')
    end

    def size_or_status
      return helpers.number_to_human_size(@export.file.byte_size) if @export.file.attached?

      t("exports.status.#{@export.status}")
    end
  end
end
