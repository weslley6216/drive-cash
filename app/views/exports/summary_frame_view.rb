module Exports
  class SummaryFrameView < ApplicationView
    def initialize(payload:, period_label:, format:)
      @totals = payload.totals
      @period_label = period_label
      @format = format
    end

    def view_template
      turbo_frame_tag 'export-summary' do
        div(class: 'bg-white rounded-2xl border border-slate-200 p-5 sticky top-8') do
          p(class: 'text-sm font-bold text-slate-800 mb-3') { t('exports.summary.title') }
          summary_box
          submit_button
          p(class: 'text-[11px] text-slate-400 text-center mt-2') { t('exports.async_hint') }
        end
      end
    end

    private

    def summary_box
      div(class: 'rounded-xl bg-slate-50 border border-slate-200 p-4 space-y-2.5 mb-4') do
        row(t('exports.summary.period'), @period_label, value_class: 'text-slate-800')
        row(t('exports.summary.entries'), @totals[:count].to_s, value_class: 'text-slate-800')
        row(t('exports.summary.earnings'), helpers.number_to_currency(@totals[:earnings]), value_class: 'text-emerald-700')
        row(t('exports.summary.expenses'), helpers.number_to_currency(@totals[:expenses]), value_class: 'text-red-700')
        div(class: 'h-px bg-slate-200')
        row(t('exports.summary.profit'), helpers.number_to_currency(@totals[:profit]), label_class: 'text-slate-600 font-medium', value_class: 'font-bold text-blue-700')
      end
    end

    def row(label, value, label_class: 'text-slate-500', value_class: 'text-slate-800')
      div(class: 'flex justify-between text-sm') do
        span(class: label_class) { label }
        span(class: "font-medium #{value_class}") { value }
      end
    end

    def submit_button
      button(type: 'submit', form: 'export-form', class: 'w-full rounded-lg py-3 text-sm font-semibold text-white flex items-center justify-center gap-2 bg-blue-600 hover:bg-blue-700 cursor-pointer') do
        render PhlexIcons::Lucide::Download.new(class: 'w-[17px] h-[17px]')
        plain t("exports.cta_format.#{@format}")
      end
    end
  end
end
