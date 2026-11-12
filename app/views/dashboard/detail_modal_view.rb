module Dashboard
  class DetailModalView < ApplicationView
    private

    def render_detail_modal(theme:)
      turbo_frame_tag 'modal' do
        div(
          class: modal_backdrop_classes,
          data:  { controller: 'modal', action: 'mousedown->modal#handleBackgroundClick' }
        ) do
          div(class: "#{DETAIL_CARD} #{DETAIL_ACCENTS.fetch(theme)[:border]} relative") do
            div(id: 'flash_modal')
            yield
          end
        end
      end
    end

    def render_detail_header(title:, subtitle:)
      div(class: 'px-5 py-4 flex items-start justify-between gap-3 border-b border-slate-100') do
        div(class: 'min-w-0') do
          h2(class: "text-lg font-bold tracking-tight #{DETAIL_ACCENTS.fetch(@theme)[:title]} truncate") { title }
          p(class: 'text-sm text-slate-500 mt-0.5') { subtitle }
        end
        button(
          type:  'button',
          data:  { action: 'modal#close' },
          class: 'w-8 h-8 rounded-full hover:bg-slate-100 flex items-center justify-center text-slate-400 flex-shrink-0 cursor-pointer'
        ) { render PhlexIcons::Lucide::X.new(class: 'w-[18px] h-[18px]') }
      end
    end

    def detail_title
      @annual ? t('.title') : t('.title_month')
    end

    def total_class
      DETAIL_ACCENTS.fetch(@theme)[:total]
    end

    def chevron
      render PhlexIcons::Lucide::ChevronRight.new(class: 'w-[15px] h-[15px] text-slate-300')
    end

    def period_subtitle(filters)
      if filters[:month].present?
        I18n.l(Date.new(filters[:year], filters[:month], 1), format: :month_dot_year).capitalize
      else
        filters[:year].to_s
      end
    end

    def render_detail_footer(annual:, show_total:, total:, back_path:, labels:)
      div(class: 'border-t border-slate-200 bg-white') do
        if show_total
          div(class: 'flex justify-between items-center py-3 px-5 font-bold bg-slate-50 border-b border-slate-100') do
            span(class: 'text-slate-800') { labels[:total] }
            span(class: total_class) { format_currency(total) }
          end
        end

        div(class: 'px-5 py-3 flex justify-between items-center') do
          div(class: 'min-h-9 flex items-center') do
            render_back_link(path: back_path, label: labels[:back]) unless annual
          end

          button(
            type:       'button',
            data:       { action: 'modal#close' },
            class:      'px-4 py-2 rounded-lg border border-slate-300 text-slate-700 text-sm font-medium hover:bg-slate-50 transition-colors cursor-pointer',
            aria_label: labels[:close]
          ) { labels[:close] }
        end
      end
    end

    def render_record_actions(edit_path:, delete_path:, edit_hover:, labels:)
      link_to(
        edit_path,
        data:  { turbo_frame: 'modal' },
        class: "inline-flex items-center h-11 -my-[14.5px] text-slate-300 #{edit_hover} transition-colors",
        aria:  { label: labels[:edit] },
        title: labels[:edit]
      ) do
        render PhlexIcons::Lucide::Pencil.new(class: 'w-[15px] h-[15px]')
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
          class:      'inline-flex items-center h-11 -my-[14.5px] text-slate-300 hover:text-red-500 transition-colors cursor-pointer',
          data:       { action: 'click->confirm-action#open' },
          aria_label: labels[:delete],
          title:      labels[:delete]
        ) do
          render PhlexIcons::Lucide::Trash2.new(class: 'w-[15px] h-[15px]')
        end
      end
    end

    def render_back_link(path:, label:)
      link_to(
        path,
        data:  { turbo_frame: 'modal' },
        class: 'text-slate-400 hover:text-slate-600 transition-colors p-2 -ml-2 rounded-full hover:bg-slate-100',
        aria:  { label: label },
        title: label
      ) do
        render PhlexIcons::Lucide::ArrowLeft.new(class: 'w-5 h-5')
      end
    end

    def format_date(date)
      I18n.l(date, format: :day_month)
    end
  end
end
