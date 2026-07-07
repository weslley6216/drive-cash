module Exports
  class RecentRowView < ApplicationView
    def initialize(export:, last:)
      @export = export
      @last = last
    end

    def view_template
      turbo_frame_tag("export_#{@export.id}", **frame_attrs) do
        if @export.status_failed?
          failed_row
        else
          linked_row
        end
      end
    end

    private

    def frame_attrs
      return {} if @export.status_done? || @export.status_failed?

      {
        src:  helpers.row_export_path(@export),
        data: {
          controller:                     'export-row-poll',
          export_row_poll_interval_value: 4000
        }
      }
    end

    def row_classes
      "flex items-center gap-3 px-4 py-3 #{'border-b border-slate-100' unless @last}"
    end

    def linked_row
      link_to(export_path(@export), class: row_classes) do
        icon
        info
        span(class: 'text-slate-400') { render PhlexIcons::Lucide::Download.new(class: 'w-[18px] h-[18px]') }
      end
    end

    def failed_row
      div(class: row_classes) do
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
      return t('exports.flash.failed') if @export.status_failed?
      return helpers.number_to_human_size(@export.file.byte_size) if @export.file.attached?

      t('exports.flash.not_ready')
    end
  end
end
