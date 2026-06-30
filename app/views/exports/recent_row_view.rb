module Exports
  class RecentRowView < ApplicationView
    def initialize(export:, last:)
      @export = export
      @last = last
    end

    def view_template
      turbo_frame_tag "export_#{@export.id}" do
        link_to(export_path(@export), class: "flex items-center gap-3 px-4 py-3 #{'border-b border-slate-100' unless @last}") do
          icon
          info
          span(class: 'text-slate-400') { render PhlexIcons::Lucide::Download.new(class: 'w-[18px] h-[18px]') }
        end
      end
    end

    private

    def icon
      div(class: 'w-9 h-9 rounded-lg bg-slate-100 text-slate-500 flex items-center justify-center flex-shrink-0') do
        render PhlexIcons::Lucide::FileText.new(class: 'w-[17px] h-[17px]')
      end
    end

    def info
      div(class: 'flex-1 min-w-0') do
        p(class: 'text-sm font-medium text-slate-800 truncate') { "DriveCash · #{@export.display_name}" }
        p(class: 'text-xs text-slate-500') { meta }
      end
    end

    def meta
      [@export.format.upcase, size_or_status, I18n.l(@export.created_at, format: :short)].compact.join(' · ')
    end

    def size_or_status
      @export.file.attached? ? helpers.number_to_human_size(@export.file.byte_size) : t('exports.flash.not_ready')
    end
  end
end
