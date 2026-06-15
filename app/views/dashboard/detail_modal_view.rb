module Dashboard
  class DetailModalView < ApplicationView
    private

    def render_detail_modal(theme:)
      turbo_frame_tag 'modal' do
        div(
          class: modal_backdrop_classes,
          data:  { controller: 'modal', action: 'mousedown->modal#handleBackgroundClick' }
        ) do
          div(class: "#{modal_content_classes} #{modal_theme_classes(theme: theme)} max-w-lg flex flex-col max-h-[90vh] relative") do
            div(id: 'flash_modal')
            yield
          end
        end
      end
    end

    def period_subtitle(filters)
      if filters[:month].present?
        I18n.l(Date.new(filters[:year], filters[:month], 1), format: :month_and_year)
      else
        filters[:year].to_s
      end
    end

    def render_detail_footer(annual:, show_total:, total:, total_class:, back_path:, labels:, padding_classes:)
      div(class: 'border-t border-slate-200 bg-white') do
        if show_total
          div(class: "flex justify-between items-center py-3 #{padding_classes} font-bold bg-slate-50 border-b border-slate-100") do
            span(class: 'text-slate-800') { labels[:total] }
            span(class: total_class) { format_currency(total) }
          end
        end

        div(class: "#{padding_classes} py-3 flex justify-between items-center") do
          div(class: 'min-h-[2.5rem] flex items-center') do
            render_back_link(path: back_path, label: labels[:back]) unless annual
          end

          button(
            type:       'button',
            data:       { action: 'modal#close' },
            class:      'px-4 py-2 rounded-lg border border-slate-300 text-slate-700 hover:bg-slate-50 transition-colors cursor-pointer',
            aria_label: labels[:close]
          ) { labels[:close] }
        end
      end
    end

    def render_record_actions(edit_path:, delete_path:, edit_hover:, labels:)
      link_to(
        edit_path,
        data:       { turbo_frame: 'modal' },
        class:      "text-slate-400 #{edit_hover} transition-colors",
        aria_label: labels[:edit],
        title:      labels[:edit]
      ) do
        render PhlexIcons::Lucide::Pencil.new(class: 'w-4 h-4')
      end

      div(data: { controller: 'delete-confirm' }) do
        button(
          type:       'button',
          class:      'text-slate-400 hover:text-red-500 transition-colors cursor-pointer',
          data:       { action: 'click->delete-confirm#open' },
          aria_label: labels[:delete],
          title:      labels[:delete]
        ) do
          render PhlexIcons::Lucide::Trash2.new(class: 'w-4 h-4')
        end

        delete_overlay(delete_path: delete_path, labels: labels)
      end
    end

    def delete_overlay(delete_path:, labels:)
      div(class: 'fixed inset-0 z-[60] hidden', data: { 'delete-confirm-target': 'overlay' }) do
        div(class: 'absolute inset-0 bg-slate-900/40', data: { action: 'click->delete-confirm#dismiss' })
        delete_sheet_mobile(delete_path: delete_path, labels: labels)
        delete_modal_desktop(delete_path: delete_path, labels: labels)
      end
    end

    def delete_sheet_mobile(delete_path:, labels:)
      div(class: 'absolute left-0 right-0 bottom-0 bg-white rounded-t-3xl px-6 pt-3 pb-9 shadow-2xl lg:hidden') do
        div(class: 'w-10 h-1 rounded-full bg-slate-200 mx-auto mb-5')
        div(class: 'w-14 h-14 rounded-full bg-red-50 text-red-600 flex items-center justify-center mx-auto') do
          render PhlexIcons::Lucide::Trash2.new(class: 'w-6 h-6')
        end
        h2(class: 'text-xl font-bold text-slate-900 text-center mt-4') { labels[:confirm] }
        div(class: 'space-y-2.5 mt-6') do
          raw helpers.button_to(labels[:delete], delete_path, method: :delete,
                                                              form:   { class: 'contents' },
                                                              class:  'w-full bg-red-600 hover:bg-red-700 text-white rounded-xl py-3.5 text-sm font-semibold cursor-pointer')
          button(type: 'button', class: 'w-full bg-slate-100 text-slate-700 rounded-xl py-3.5 text-sm font-semibold cursor-pointer',
                 data: { action: 'click->delete-confirm#dismiss' }) { t('ui.cancel') }
        end
      end
    end

    def delete_modal_desktop(delete_path:, labels:)
      div(class: 'absolute inset-0 hidden lg:flex items-center justify-center p-8') do
        div(class: 'bg-white rounded-2xl shadow-2xl border border-slate-200 w-full max-w-md p-6') do
          div(class: 'w-14 h-14 rounded-full bg-red-50 text-red-600 flex items-center justify-center') do
            render PhlexIcons::Lucide::Trash2.new(class: 'w-6 h-6')
          end
          h2(class: 'text-xl font-bold text-slate-900 mt-4') { labels[:confirm] }
          div(class: 'flex items-center justify-end gap-3 mt-6') do
            button(type: 'button', class: 'px-4 py-2 text-sm font-semibold text-slate-600 hover:text-slate-900 cursor-pointer',
                   data: { action: 'click->delete-confirm#dismiss' }) { t('ui.cancel') }
            raw helpers.button_to(labels[:delete], delete_path, method: :delete,
                                                                form:   { class: 'contents' },
                                                                class:  'px-5 py-2 text-sm font-semibold text-white bg-red-600 hover:bg-red-700 rounded-lg cursor-pointer')
          end
        end
      end
    end

    def render_back_link(path:, label:)
      link_to(
        path,
        data:       { turbo_frame: 'modal' },
        class:      'text-slate-400 hover:text-slate-600 transition-colors p-2 -ml-2 rounded-full hover:bg-slate-100',
        aria_label: label,
        title:      label
      ) do
        render PhlexIcons::Lucide::ArrowLeft.new(class: 'w-6 h-6')
      end
    end

    def format_date(date)
      I18n.l(date, format: :short)
    end
  end
end
