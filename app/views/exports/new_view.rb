module Exports
  class NewView < ApplicationView
    PERIOD_KINDS = %w[this_month last_month year custom].freeze
    INCLUDE_ROWS = [
      { key: 'earnings', icon: PhlexIcons::Lucide::DollarSign },
      { key: 'expenses', icon: PhlexIcons::Lucide::Receipt },
      { key: 'refuelings', icon: PhlexIcons::Lucide::Fuel },
      { key: 'maintenances', icon: PhlexIcons::Lucide::Wrench }
    ].freeze

    def initialize(export:, exports:)
      @export = export
      @exports = exports
    end

    def view_template
      render LayoutComponent.new(title: t('exports.title'), bottom_nav: :more, sidebar_nav: :more) do
        div(id: 'flash') { render FlashComponent.new(flash: helpers.flash) }
        mobile_layout
        desktop_layout
      end
    end

    private

    def mobile_layout
      div(class: 'lg:hidden') do
        mobile_header
        form_with(model: @export, url: exports_path, method: :post, local: true, class: 'pb-28') do |f|
          div(class: 'px-5 space-y-5') do
            why_block
            period_chips_mobile(f)
            format_pills(mobile: true)
            include_card
            recents_card
          end
          mobile_cta
        end
      end
    end

    def desktop_layout
      div(class: 'hidden lg:block') do
        desktop_header
        form_with(model: @export, url: exports_path, method: :post, local: true) do |f|
          div(class: 'grid grid-cols-[1fr_360px] gap-8 items-start max-w-5xl') do
            div(class: 'space-y-6') do
              desktop_panel(t('exports.period.label')) { period_chips_desktop(f) }
              desktop_panel(t('exports.format.label')) { format_pills(mobile: false) }
              include_panel_desktop
            end
            summary_panel_desktop
          end
        end
      end
    end

    def mobile_header
      header(class: 'px-5 pt-2 pb-3') do
        div(class: 'flex items-center gap-3') do
          link_to(account_path, class: 'w-9 h-9 rounded-full bg-white border border-slate-200 shadow-sm flex items-center justify-center text-slate-600') do
            render PhlexIcons::Lucide::ArrowLeft.new(class: 'w-[18px] h-[18px]')
          end
          div do
            h1(class: 'text-xl font-bold text-slate-900') { t('exports.title') }
            p(class: 'text-xs text-slate-500') { t('exports.subtitle') }
          end
        end
      end
    end

    def desktop_header
      div(class: 'mb-6') do
        h1(class: 'text-2xl font-bold text-slate-800') { t('exports.desktop_title') }
        p(class: 'text-sm text-slate-500 mt-1') { t('exports.desktop_subtitle') }
      end
    end

    def why_block
      div(class: 'rounded-2xl bg-blue-50 border border-blue-200 p-3.5 flex items-start gap-2.5') do
        render PhlexIcons::Lucide::FileText.new(class: 'w-[17px] h-[17px] text-blue-600 flex-shrink-0 mt-0.5')
        p(class: 'text-xs text-blue-800 leading-snug') { t('exports.why') }
      end
    end

    def period_chips_mobile(_form)
      div do
        p(class: 'text-xs font-bold text-slate-500 uppercase tracking-wider mb-2.5') { t('exports.period.label') }
        div(class: 'flex flex-wrap gap-2') do
          PERIOD_KINDS.each { |kind| period_button(kind, mobile: true) }
        end
        period_dates_fields
      end
    end

    def period_chips_desktop(_form)
      div(class: 'flex flex-wrap gap-2') do
        PERIOD_KINDS.each { |kind| period_button(kind, mobile: false) }
      end
      period_dates_fields
    end

    def period_button(kind, mobile:)
      selected = (@export.period_kind || 'year') == kind
      classes = mobile ? mobile_chip_classes(selected) : desktop_chip_classes(selected)
      label(class: classes) do
        input(type: 'radio', name: 'export[period_kind]', value: kind, checked: selected, class: 'sr-only')
        plain period_label(kind)
      end
    end

    def mobile_chip_classes(selected)
      base = 'rounded-full px-3.5 py-2 text-sm font-medium border cursor-pointer'
      selected ? "#{base} bg-slate-800 text-white border-slate-800" : "#{base} bg-white text-slate-600 border-slate-200"
    end

    def desktop_chip_classes(selected)
      base = 'rounded-lg px-3.5 py-2 text-sm font-medium border cursor-pointer'
      selected ? "#{base} bg-blue-600 text-white border-blue-600" : "#{base} bg-white text-slate-600 border-slate-200 hover:bg-slate-50"
    end

    def period_label(kind)
      kind == 'year' ? t('exports.period.year', year: Date.current.year) : t("exports.period.#{kind}")
    end

    def period_dates_fields
      div(class: 'grid grid-cols-2 gap-3 mt-3') do
        date_field('export[period_start]', @export.period_start)
        date_field('export[period_end]', @export.period_end)
      end
    end

    def date_field(name, value)
      input(type: 'date', name: name, value: value&.iso8601, class: 'w-full px-3 py-2 rounded-lg border border-slate-300 text-sm')
    end

    def format_pills(mobile:)
      div do
        p(class: 'text-xs font-bold text-slate-500 uppercase tracking-wider mb-2.5') { t('exports.format.label') } if mobile
        div(class: 'flex gap-3') do
          render Exports::FormatPillComponent.new(
            icon:     PhlexIcons::Lucide::FileText,
            title:    t('exports.format.pdf'),
            sub:      t('exports.format.pdf_sub'),
            value:    'pdf',
            selected: (@export.format || 'pdf') == 'pdf'
          )
          render Exports::FormatPillComponent.new(
            icon:     PhlexIcons::Lucide::List,
            title:    t('exports.format.csv'),
            sub:      t('exports.format.csv_sub'),
            value:    'csv',
            selected: @export.format == 'csv'
          )
          unless mobile
            render Exports::FormatPillComponent.new(
              icon:     PhlexIcons::Lucide::Download,
              title:    t('exports.format.json'),
              sub:      t('exports.format.json_sub'),
              value:    'json',
              selected: @export.format == 'json'
            )
          end
        end
      end
    end

    def include_card
      div do
        p(class: 'text-xs font-bold text-slate-500 uppercase tracking-wider mb-2.5') { t('exports.include.label') }
        div(class: 'bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden') do
          INCLUDE_ROWS.each_with_index do |row, index|
            render Exports::IncludeRowComponent.new(
              icon:    row[:icon],
              label:   t("exports.include.#{row[:key]}"),
              sub:     t("exports.include.#{row[:key]}_sub"),
              key:     row[:key],
              checked: @export.includes_for(row[:key]),
              last:    index == INCLUDE_ROWS.size - 1
            )
          end
        end
      end
    end

    def include_panel_desktop
      div(class: 'bg-white rounded-2xl border border-slate-200 overflow-hidden') do
        p(class: 'text-xs font-bold text-slate-500 uppercase tracking-wider px-5 pt-5 pb-2') { t('exports.include.label') }
        INCLUDE_ROWS.each_with_index do |row, index|
          render Exports::IncludeRowComponent.new(
            icon:    row[:icon],
            label:   t("exports.include.#{row[:key]}"),
            sub:     t("exports.include.#{row[:key]}_sub"),
            key:     row[:key],
            checked: @export.includes_for(row[:key]),
            last:    index == INCLUDE_ROWS.size - 1
          )
        end
      end
    end

    def desktop_panel(label, &block)
      div(class: 'bg-white rounded-2xl border border-slate-200 p-5') do
        p(class: 'text-xs font-bold text-slate-500 uppercase tracking-wider mb-3') { label }
        block.call
      end
    end

    def summary_panel_desktop
      div(class: 'bg-white rounded-2xl border border-slate-200 p-5 sticky top-8') do
        p(class: 'text-sm font-bold text-slate-800 mb-3') { t('exports.summary.title') }
        div(class: 'rounded-xl bg-slate-50 border border-slate-200 p-4 space-y-2.5 mb-4') do
          summary_row(t('exports.summary.period'), period_label(@export.period_kind || 'year'), value_class: 'text-slate-800')
        end
        button(type: 'submit', class: 'w-full rounded-lg py-3 text-sm font-semibold text-white flex items-center justify-center gap-2 bg-blue-600 hover:bg-blue-700 cursor-pointer') do
          render PhlexIcons::Lucide::Download.new(class: 'w-[17px] h-[17px]')
          plain t('exports.cta')
        end
        p(class: 'text-[11px] text-slate-400 text-center mt-2') { t('exports.async_hint') }
      end
    end

    def summary_row(label, value, value_class: 'text-slate-800')
      div(class: 'flex justify-between text-sm') do
        span(class: 'text-slate-500') { label }
        span(class: "font-medium #{value_class}") { value }
      end
    end

    def recents_card
      div do
        p(class: 'text-xs font-bold text-slate-500 uppercase tracking-wider mb-2.5') { t('exports.recents') }
        div(class: 'bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden') do
          if @exports.empty?
            p(class: 'p-5 text-sm text-slate-500 text-center') { t('exports.empty_recents') }
          else
            @exports.each_with_index { |export, index| recent_row(export, last: index == @exports.size - 1) }
          end
        end
      end
    end

    def recent_row(export, last:)
      link_to(export_path(export), class: "flex items-center gap-3 px-4 py-3 #{'border-b border-slate-100' unless last}") do
        div(class: 'w-9 h-9 rounded-lg bg-slate-100 text-slate-500 flex items-center justify-center flex-shrink-0') do
          render PhlexIcons::Lucide::FileText.new(class: 'w-[17px] h-[17px]')
        end
        div(class: 'flex-1 min-w-0') do
          p(class: 'text-sm font-medium text-slate-800 truncate') { recent_name(export) }
          p(class: 'text-xs text-slate-500') { recent_meta(export) }
        end
        span(class: 'text-slate-400') { render PhlexIcons::Lucide::Download.new(class: 'w-[18px] h-[18px]') }
      end
    end

    def recent_name(export)
      "DriveCash · #{I18n.l(export.created_at.to_date, format: :short)}"
    end

    def recent_meta(export)
      [export.format.upcase, recent_size(export), I18n.l(export.created_at, format: :short)].compact.join(' · ')
    end

    def recent_size(export)
      export.file.attached? ? helpers.number_to_human_size(export.file.byte_size) : t('exports.flash.not_ready')
    end

    def mobile_cta
      div(class: 'fixed bottom-0 left-0 right-0 px-5 pt-3 pb-7 border-t border-slate-100 bg-white lg:hidden') do
        button(type: 'submit', class: 'w-full rounded-xl py-3.5 text-base font-semibold text-white flex items-center justify-center gap-2 shadow-lg bg-blue-600 shadow-blue-600/20 cursor-pointer') do
          render PhlexIcons::Lucide::Download.new(class: 'w-[18px] h-[18px]')
          plain t('exports.cta')
        end
      end
    end
  end
end
