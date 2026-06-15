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

      render ConfirmActionComponent.new(
        title:          labels[:confirm],
        icon:           PhlexIcons::Lucide::Trash2,
        confirm_path:   delete_path,
        confirm_method: :delete,
        confirm_label:  labels[:delete],
        cancel_label:   labels[:cancel],
        description:    labels[:description]
      ) do
        button(
          type:       'button',
          class:      'text-slate-400 hover:text-red-500 transition-colors cursor-pointer',
          data:       { action: 'click->confirm-action#open' },
          aria_label: labels[:delete],
          title:      labels[:delete]
        ) do
          render PhlexIcons::Lucide::Trash2.new(class: 'w-4 h-4')
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
