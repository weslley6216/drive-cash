module Help
  class ShowView < ApplicationView
    def view_template
      render LayoutComponent.new(title: t('.title'), bottom_nav: :more, sidebar_nav: :more) do
        mobile_header
        div(class: 'px-5 lg:px-0 pb-10 space-y-6') do
          faq_section
          contact_section
          about_section
        end
      end
    end

    private

    def faqs = t('.faqs')

    def mobile_header
      header(class: 'px-5 lg:px-1 pt-2 pb-3') do
        div(class: 'flex items-center gap-3') do
          link_to(helpers.account_path, class: 'w-9 h-9 rounded-full bg-white border border-slate-200 shadow-sm flex items-center justify-center text-slate-600 lg:hidden') do
            render PhlexIcons::Lucide::ArrowLeft.new(class: 'w-[18px] h-[18px]')
          end
          div do
            h1(class: 'text-xl lg:text-2xl font-bold text-slate-900') { t('.heading') }
            p(class: 'text-xs lg:text-sm text-slate-500') { t('.subtitle') }
          end
        end
      end
    end

    def faq_section
      div(class: 'max-w-2xl') do
        p(class: 'text-xs font-semibold text-slate-400 uppercase tracking-wider mb-2 px-1') { t('.faq_title') }
        div(class: 'bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden') do
          faqs.each_with_index { |faq, index| faq_item(faq, last: index == faqs.size - 1) }
        end
      end
    end

    def faq_item(faq, last:)
      div(class: (last ? '' : 'border-b border-slate-100'), data: { controller: 'disclosure' }) do
        button(type: 'button', data: { action: 'disclosure#toggle' }, class: 'w-full flex items-center gap-3 px-4 py-3.5 text-left') do
          p(class: 'text-sm font-semibold text-slate-800 flex-1') { faq[:question] }
          span(data: { disclosure_target: 'iconClosed' }) { render PhlexIcons::Lucide::ChevronDown.new(class: 'w-4 h-4 text-slate-400 flex-shrink-0') }
          span(class: 'hidden', data: { disclosure_target: 'iconOpen' }) { render PhlexIcons::Lucide::ChevronUp.new(class: 'w-4 h-4 text-slate-400 flex-shrink-0') }
        end
        p(class: 'hidden px-4 pb-4 text-sm text-slate-600 leading-relaxed', data: { disclosure_target: 'panel' }) { faq[:answer] }
      end
    end

    def contact_section
      div(class: 'max-w-2xl') do
        p(class: 'text-xs font-semibold text-slate-400 uppercase tracking-wider mb-2 px-1') { t('.contact_title') }
        div(class: 'grid grid-cols-2 gap-3') do
          contact_card(helpers.coming_soon_path, PhlexIcons::Lucide::MessageCircle, 'bg-emerald-50 text-emerald-600', t('.whatsapp'), t('.whatsapp_sub'))
          contact_card('mailto:ajuda@drivecash.app', PhlexIcons::Lucide::Send, 'bg-blue-50 text-blue-600', t('.email'), t('.email_sub'))
        end
      end
    end

    def contact_card(href, icon, icon_classes, title, subtitle)
      link_to(href, class: 'bg-white rounded-2xl border border-slate-100 shadow-sm p-4 block hover:bg-slate-50') do
        div(class: "w-9 h-9 rounded-lg #{icon_classes} flex items-center justify-center mb-2") do
          render icon.new(class: 'w-[17px] h-[17px]')
        end
        p(class: 'text-sm font-semibold text-slate-800') { title }
        p(class: 'text-[11px] text-slate-500 mt-0.5') { subtitle }
      end
    end

    def about_section
      div(class: 'max-w-2xl') do
        p(class: 'text-xs font-semibold text-slate-400 uppercase tracking-wider mb-2 px-1') { t('.about_title') }
        div(class: 'bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden') do
          about_version
          about_link(t('.terms'))
          about_link(t('.privacy'), last: true)
        end
      end
    end

    def about_version
      div(class: 'w-full flex items-center gap-3 px-4 py-3.5 border-b border-slate-100') do
        span(class: 'text-sm font-medium text-slate-800 flex-1') { t('.version_label') }
        span(class: 'text-sm text-slate-500 tabular-nums') { Account::ShowView::APP_VERSION }
      end
    end

    def about_link(label, last: false)
      link_to(helpers.coming_soon_path, class: "w-full flex items-center gap-3 px-4 py-3.5 hover:bg-slate-50 #{'border-b border-slate-100' unless last}") do
        span(class: 'text-sm font-medium text-slate-800 flex-1') { label }
        render PhlexIcons::Lucide::ChevronRight.new(class: 'w-4 h-4 text-slate-300')
      end
    end
  end
end
